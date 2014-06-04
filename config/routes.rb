Rails.application.routes.draw do
  resources :locations

  resources :zones

  get 'dashboard/index'

  devise_for :users

  root to: 'dashboard#index'
end
