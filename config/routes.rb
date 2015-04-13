Rails.application.routes.draw do
  root to: 'home#home'
  get 'home'  => 'home#home'
  get 'about' => 'home#about'

  devise_for :users

  resources :users, only: [:show]

  resources :clients

  resources :projects
end
