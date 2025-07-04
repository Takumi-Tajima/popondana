class BooksController < ApplicationController
  before_action :authenticate_user!

  def index
    @ownerships = current_user.ownerships.includes(:book, :categories)
    
    # カテゴリーごとにグループ化
    @books_by_category = {}
    @ownerships.each do |ownership|
      if ownership.categories.empty?
        @books_by_category["未分類"] ||= []
        @books_by_category["未分類"] << ownership
      else
        ownership.categories.each do |category|
          @books_by_category[category.name] ||= []
          @books_by_category[category.name] << ownership
        end
      end
    end
  end

  def search
    @query = params[:query]
    @books = []

    if @query.present?
      api = RakutenBooksApi.new
      @results = api.search_by_title(@query)
      
      # 既に登録されている書籍のISBNリストを取得
      existing_isbns = Book.where(isbn: @results.map { |r| r[:isbn] }).pluck(:isbn)
      
      # ユーザーが所有している書籍のISBNリストを取得
      owned_isbns = current_user.books.where(isbn: @results.map { |r| r[:isbn] }).pluck(:isbn)
      
      @results.map! do |result|
        result[:already_exists] = existing_isbns.include?(result[:isbn])
        result[:already_owned] = owned_isbns.include?(result[:isbn])
        result
      end
    end
  end

  private

  def authenticate_user!
    redirect_to root_path unless current_user
  end
end
