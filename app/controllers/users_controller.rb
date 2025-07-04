class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [:show]

  def index
    @users = User.includes(ownerships: :categories)
    @categories = Category.order(:name)
    
    # 検索フィルタを適用
    @users = apply_search_filters(@users)
    
    # カテゴリーごとの本の数を計算し、所有数でソート
    @user_stats = @users.map do |user|
      category_counts = user.ownerships
        .joins(:categories)
        .group('categories.name')
        .count
        .sort_by { |_, count| -count }
        .first(5)
      
      {
        user: user,
        total_books: user.ownerships.count,
        top_categories: category_counts
      }
    end.sort_by { |stat| -stat[:total_books] }
    
    # ランキングを追加
    @user_stats.each_with_index do |stat, index|
      stat[:rank] = index + 1
    end
  end

  def show
    @ownerships = @user.ownerships.includes(:book, :categories)
    @categories = Category.joins(ownerships: :user).where(users: { id: @user.id }).distinct.order(:name)
    
    # 検索フィルタを適用
    @ownerships = apply_ownership_filters(@ownerships)
    
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
    
    # グラフ用のデータを準備（絞り込み条件を適用）
    @chart_data = prepare_chart_data(@user, @ownerships)
  end

  private

  def authenticate_user!
    redirect_to root_path unless current_user
  end
  
  def set_user
    @user = User.find(params[:id])
  end
  
  def prepare_chart_data(user, ownerships = nil)
    # データソースを決定
    ownerships ||= user.ownerships
    
    # 最新12ヶ月のデータを準備
    start_date = 11.months.ago.beginning_of_month
    end_date = Date.current.end_of_month
    
    # 月ごとの登録数を集計。PostgreSQLのSQLite対応版
    monthly_counts = {}
    ownerships.where(owned_at: start_date..end_date).find_each do |ownership|
      month_key = ownership.owned_at.beginning_of_month
      monthly_counts[month_key] = (monthly_counts[month_key] || 0) + 1
    end
    
    # 12ヶ月分のラベルとデータを作成
    labels = []
    data = []
    
    (0..11).each do |i|
      month = i.months.ago.beginning_of_month
      labels.unshift(month.strftime('%Y年%m月'))
      data.unshift(monthly_counts[month] || 0)
    end
    
    {
      labels: labels,
      data: data
    }
  end
  
  def apply_search_filters(users)
    # カテゴリで絞り込み
    if params[:category_id].present?
      category = Category.find(params[:category_id])
      users = users.joins(ownerships: :categories).where(categories: { id: category.id }).distinct
    end
    
    # 期間で絞り込み
    if params[:start_date].present? || params[:end_date].present?
      start_date = params[:start_date].present? ? Date.parse(params[:start_date]) : Date.new(1900, 1, 1)
      end_date = params[:end_date].present? ? Date.parse(params[:end_date]) : Date.current
      
      users = users.joins(:ownerships).where(ownerships: { owned_at: start_date..end_date }).distinct
    end
    
    users
  end
  
  def apply_ownership_filters(ownerships)
    # カテゴリで絞り込み
    if params[:category_filter].present?
      category = Category.find(params[:category_filter])
      ownerships = ownerships.joins(:categories).where(categories: { id: category.id })
    end
    
    # 期間で絞り込み
    if params[:start_date_filter].present? || params[:end_date_filter].present?
      start_date = params[:start_date_filter].present? ? Date.parse(params[:start_date_filter]) : Date.new(1900, 1, 1)
      end_date = params[:end_date_filter].present? ? Date.parse(params[:end_date_filter]) : Date.current
      
      ownerships = ownerships.where(owned_at: start_date..end_date)
    end
    
    ownerships
  end
end
