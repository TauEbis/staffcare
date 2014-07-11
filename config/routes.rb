Rails.application.routes.draw do
  resources :schedules do
    resources :location_plans, shallow: true, only: [:index, :show, :update]
  end

  resources :location_plans, only: [] do
    collection do
      post :change_state
    end
  end

  resources :grades, only: [:create, :show, :update, :destroy] do
    member do
      get :hourly
    end
  end

  resources :locations

  resources :zones

  devise_for :users, skip: [:registrations]
  resources :users, except: [:show] do
    member do
      get  'profile'
      post 'update_profile'
    end
  end

  get 'dashboard/index'

  require 'sidekiq/web'
  require 'sidekiq-status/web'

  authenticate :user, lambda { |u| u.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end

  root to: 'dashboard#index'
end
