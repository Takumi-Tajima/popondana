class OwnershipsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_ownership, only: [:show, :destroy, :update_categories]

  def show
    render json: { 
      ownership_id: @ownership.id, 
      category_ids: @ownership.categories.pluck(:id) 
    }
  end

  def create
    book_data = JSON.parse(params[:book_data])
    
    # 既存の書籍を検索、なければ作成
    book = Book.find_or_create_by(isbn: book_data['isbn']) do |b|
      b.title = book_data['title']
      b.author = book_data['author']
      b.publisher = book_data['publisher']
      b.published_date = book_data['published_date']
      b.image_url = book_data['image_url']
      b.rakuten_url = book_data['rakuten_url']
    end
    
    # 所有権を作成
    ownership = current_user.ownerships.find_or_create_by(book: book)
    
    # カテゴリを処理
    if params[:category_ids].present?
      categories = Category.where(id: params[:category_ids])
      ownership.categories = categories
    end
    
    if params[:new_categories].present?
      params[:new_categories].each do |category_name|
        next if category_name.blank?
        
        category = Category.find_or_create_by(name: category_name)
        ownership.categories << category unless ownership.categories.include?(category)
      end
    end
    
    if ownership.persisted?
      render json: { status: 'success', ownership_id: ownership.id }
    else
      render json: { status: 'error', errors: ownership.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @ownership.destroy
    redirect_to books_path, notice: '書籍の所有を解除しました。'
  end

  def update_categories
    # カテゴリを更新
    if params[:category_ids].present?
      categories = Category.where(id: params[:category_ids])
      @ownership.categories = categories
    else
      @ownership.categories.clear
    end
    
    if params[:new_categories].present?
      params[:new_categories].each do |category_name|
        next if category_name.blank?
        
        category = Category.find_or_create_by(name: category_name)
        @ownership.categories << category unless @ownership.categories.include?(category)
      end
    end
    
    render json: { status: 'success' }
  end

  private

  def authenticate_user!
    redirect_to root_path unless current_user
  end
  
  def set_ownership
    @ownership = current_user.ownerships.find(params[:id])
  end
end
