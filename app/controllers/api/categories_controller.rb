class Api::CategoriesController < ApplicationController
  before_action :authenticate_user!
  
  def index
    categories = Category.order(:name)
    render json: categories.as_json(only: [:id, :name])
  end
  
  private
  
  def authenticate_user!
    render json: { error: 'Unauthorized' }, status: :unauthorized unless current_user
  end
end
