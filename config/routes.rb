Rails.application.routes.draw do
  resources :locations

  resources :zones

  devise_for :users, skip: [:registrations]
  resources :users

  get 'dashboard/index'


  root to: 'dashboard#index'
end
