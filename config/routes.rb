Rails.application.routes.draw do
  resources :life_cycles, except: [:show]

  resources :pages

  resources :pushes, only: [:index, :new, :create, :show] do
    collection do
      get :confirm
    end
  end

  resources :schedules do
    member do
      get :request_approvals
    end
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
      get :highcharts
    end
  end

  resources :patient_volume_forecasts, except: [:show] do
    collection { post :import }
  end

  resources :locations

  resources :zones

  resources :heatmaps, only: [:index, :show]

  resources :speeds, only: [:destroy]

  devise_for :users, skip: [:registrations]
  resources :users, except: [:show] do
    member do
      get  'profile'
      post 'update_profile'
    end
  end

  get 'dashboard/index'
  get 'dashboard/status'

  require 'sidekiq/web'
  require 'sidekiq-status/web'

  authenticate :user, lambda { |u| u.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end

  root to: 'dashboard#index'
end
