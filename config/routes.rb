Rails.application.routes.draw do
  root to: "home#home"
  get "home"  => "home#home"
  get "about" => "home#about"
  get "keepalive" => "home#keepalive"
  get "error" => "home#error"

  devise_for :users

  resources :users, only: [:show]

  resources :projects do
    collection do
      get :download
    end
  end

  resources :work_entries do
    collection do
      post :merge
      get  :download
    end
  end

  resources :invoices do
    collection do
      get :preview
      get :download
    end
  end
end
