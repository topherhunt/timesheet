Rails.application.routes.draw do
  root to: "home#home"
  get "home"  => "home#home"
  get "about" => "home#about"
  get "error" => "home#error"
  get "login_as" => "home#login_as"

  devise_for :users

  resources :users, only: [:show]

  get "/projects/:id/delete" => "projects#delete", as: :delete_project
  resources :projects

  put "/work_entries/:id/stop" => "work_entries#stop", as: :stop_work_entry
  get "/work_entries/download" => "work_entries#download", as: :download_work_entries
  get "/work_entries/:id/prior_entry" => "work_entries#prior_entry", as: :prior_work_entry
  post "/work_entries/merge" => "work_entries#merge", as: :merge_work_entries
  resources :work_entries

  resources :invoices do
    collection do
      get :preview
      get :download
    end
  end
end
