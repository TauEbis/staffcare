Rails.application.routes.draw do
  resources :schedules

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
