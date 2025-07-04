class Api::CategoriesController < ApplicationController
  before_action :authenticate_user!
  
  def index
    categories = Category.order(:name)
    render json: categories.as_json(only: [:id, :name])
  end
  
  def destroy
    category = Category.find_by(name: params[:id])
    
    if category
      category.destroy
      render json: { status: 'success', message: 'カテゴリが削除されました' }
    else
      render json: { status: 'error', message: 'カテゴリが見つかりませんでした' }, status: :not_found
    end
  end
  
  private
  
  def authenticate_user!
    render json: { error: 'Unauthorized' }, status: :unauthorized unless current_user
  end
end
