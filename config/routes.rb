Rails.application.routes.draw do
  resources :schedules do
    resources :location_plans, shallow: true, only: [:index, :show, :update]
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


  root to: 'dashboard#index'
end
