Rails.application.routes.draw do

  resources :pages

  resources :pushes, only: [:index, :new, :create, :show]

  resources :assignments

  resources :schedules do
    member do
      get :request_approvals
    end
    resources :location_plans, shallow: true, only: [:index, :show, :update]
    resource  :staffing do
      member do
        get :table
      end
    end
  end

  resources :location_plans, only: [] do
    resources :line_workers, only: [:index, :new, :create]
    resources :comments

    collection do
      post :change_state
    end
  end

  resources :grades, only: [:create, :show, :update, :destroy] do
    member do
      get :shifts
      get :hourly
      get :highcharts
      get :rules, to: "rules#index", as: 'rules'
      post :line_workers
    end
  end

  resources :rules, only: [:index, :edit, :update] do
    collection do
      get :default, to: :index, as: 'default'
    end
  end

  resources :patient_volume_forecasts, except: [:show] do
    collection { post :import }
  end

  resources :locations

  resources :zones

  resources :heatmaps, only: [:index, :show]

  resources :visits, only: [:index, :show]

  resources :short_forecasts, only: [:index, :show]

  resources :positions, only: [:index, :edit, :update]

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
  get 'staffing_analyst', to: "landing_pages#staffing_analyst", as: 'staffing_analyst'
  get 'report_server_data_and_forecasts', to: "landing_pages#report_server_data_and_forecasts", as: 'report_server_data_and_forecasts'

  require 'sidekiq/web'
  require 'sidekiq-status/web'

  authenticate :user, lambda { |u| u.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end

  root to: 'dashboard#index'
end
