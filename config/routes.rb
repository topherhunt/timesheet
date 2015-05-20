Rails.application.routes.draw do
  root to: "home#home"
  get "home"  => "home#home"
  get "about" => "home#about"
  get "keepalive" => "home#keepalive"

  devise_for :users

  resources :users, only: [:show]

  resources :clients

  resources :projects

  resources :work_entries do
    member do
      patch :stop
      patch :mark_billed
    end
  end

  resources :invoices do
    collection do
      get :preview
    end
  end
end
