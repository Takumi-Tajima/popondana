Rails.application.routes.draw do
  root 'home#index'
  
  # 認証
  get '/auth/:provider/callback', to: 'sessions#create'
  get '/auth/failure', to: 'sessions#failure'
  delete '/logout', to: 'sessions#destroy'
  
  # 書籍
  resources :books, only: [:index] do
    collection do
      get 'search'
    end
  end
  
  # 所有
  resources :ownerships, only: [:show, :create, :destroy] do
    member do
      patch 'update_categories'
    end
  end
  
  # ユーザー
  resources :users, only: [:index, :show]
  
  # API
  namespace :api do
    resources :categories, only: [:index]
  end
end
