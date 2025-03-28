class Api::V1::SubscriptionsController < ApplicationController
  include AuthenticateRequest

  before_action :set_subscription, only: [ :show, :cancel, :change_plan, :reactivate ]
  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index

  def index
    @subscriptions = policy_scope(Subscription)
    render json: @subscriptions
  end

  def show
    authorize @subscription
    render json: {
      id: @subscription.id,
      plan_name: @subscription.name,
      status: @subscription.status,
      current_period_end: @subscription.ends_at
    }
  end

  def create
    @subscription = current_user.subscriptions.build
    authorize @subscription

    plan = params[:plan_name].downcase

    # Create a Stripe subscription through Pay
    subscription = current_user.payment_processor
                               .subscribe(plan: plan,
                                        automatic_tax: true,
                                        payment_behavior: "default_incomplete",
                                        expand: [ "latest_invoice.payment_intent" ])

    @subscription = current_user.subscriptions.find_by(processor_id: subscription.processor_id)

    render json: {
      subscription_id: @subscription.id,
      status: @subscription.status,
      client_secret: subscription.client_secret
    }, status: :created
  rescue Pay::Error => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def cancel
    authorize @subscription, :cancel?

    if @subscription.cancel
      render json: {
        id: @subscription.id,
        status: @subscription.status,
        ends_at: @subscription.ends_at
      }
    else
      render json: { error: "failed to cancel subscription" }, status: :unprocessable_entity
    end
  end

  def change_plan
    authorize @subscription, :change_plan?

    new_plan = params[:plan_name].downcase

    begin
      # Update subscription through Pay
      subscription = Pay::Subscription.find_by(processor_id: @subscription.stripe_id)
      subscription.swap(new_plan)

      render json: {
        id: @subscription.id,
        plan_name: subscription.name,
        status: subscription.status,
        current_period_end: subscription.ends_at
      }
    rescue Pay::Error => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end

  def reactivate
    authorize @subscription, :reactivate?

    begin
      # Reactivate through Pay
      subscription = Pay::Subscription.find_by(processor_id: @subscription.stripe_id)
      subscription.resume

      render json: {
        id: @subscription.id,
        plan_name: subscription.name,
        status: subscription.status,
        current_period_end: subscription.ends_at
      }
    rescue Pay::Error => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end

  def payment_methods
    authorize current_user, :manage_payment_methods?
    render json: current_user.payment_methods.as_json(
      only: [ :id, :type, :last4, :exp_month, :exp_year, :default ]
    )
  end

  def attach_payment_method
    authorize current_user, :manage_payment_methods?

    begin
      # Attach payment method to customer
      payment_method = current_user.add_payment_method(params[:payment_method_id])

      # Set as default if requested or if it's the only one
      if params[:default].present? || current_user.payment_methods.count == 1
        payment_method.make_default!
      end

      render json: payment_method.as_json(
        only: [ :id, :type, :last4, :exp_month, :exp_year, :default ]
      ), status: :created
    rescue Pay::Error => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end

  def detach_payment_method
    payment_method = current_user.payment_methods.find_by(id: params[:id])
    authorize payment_method, :detach?

    if payment_method.nil?
      render json: { error: "Payment method not found" }, status: :not_found
      return
    end

    if payment_method.default?
      render json: { error: "Cannot remove default payment method" }, status: :unprocessable_entity
      return
    end

    if payment_method.detach
      render json: { success: true }, status: :ok
    else
      render json: { error: "Failed to remove payment method" }, status: :unprocessable_entity
    end
  end

  private

  def set_subscription
    @subscription = Subscription.find(params[:id])
  end
end
