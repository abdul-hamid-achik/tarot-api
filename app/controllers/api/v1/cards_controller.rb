class Api::V1::CardsController < ApplicationController
  def index
    @cards = Card.all
    render json: @cards
  end

  def show
    @card = Card.find(params[:id])
    render json: @card
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Card not found" }, status: :not_found
  end
end
