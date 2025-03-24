# This migration comes from pay (originally 2)
class AddPayStiColumns < ActiveRecord::Migration[7.0]
  def change
    # Skip migration if column already exists
    unless column_exists?(:pay_customers, :type)
      add_column :pay_customers, :type, :string
      add_index :pay_customers, :type
    end

    unless column_exists?(:pay_subscriptions, :type)
      add_column :pay_subscriptions, :type, :string
      add_index :pay_subscriptions, :type
    end

    unless column_exists?(:pay_charges, :type)
      add_column :pay_charges, :type, :string
    end

    unless column_exists?(:pay_merchants, :type)
      add_column :pay_merchants, :type, :string
    end

    # Skip the rename column operation since running the migration
    # against existing tables could cause issues
    # rename_column :pay_payment_methods, :type, :payment_method_type

    unless column_exists?(:pay_payment_methods, :type)
      add_column :pay_payment_methods, :type, :string
    end

    Pay::Customer.find_each do |pay_customer|
      pay_customer.update(type: "Pay::#{pay_customer.processor.classify}::Customer")

      pay_customer.charges.update_all(type: "Pay::#{pay_customer.processor.classify}::Charge")
      pay_customer.subscriptions.update_all(type: "Pay::#{pay_customer.processor.classify}::Subscription")
      pay_customer.payment_methods.update_all(type: "Pay::#{pay_customer.processor.classify}::PaymentMethod")
    end

    Pay::Merchant.find_each do |pay_merchant|
      pay_merchant.update(type: "Pay::#{pay_merchant.processor.classify}::Merchant")
    end
  end
end
