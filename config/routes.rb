Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  get  "login",  to: "sessions#new"
  post "login",  to: "sessions#create"
  delete "logout", to: "sessions#destroy"

  get "dashboard", to: "dashboards#show"
  get "approval_dashboard", to: "dashboards#approvals"
  get "admin",     to: "admin#show"
  get "analytics", to: "analytics#show"

  resources :bookings do
    member do
      patch :approve
      patch :reject
      patch :mark_returned
    end
    collection do
      post :confirm
      get :my
    end
  end
  resources :venues
  get "home/index"

  resources :equipments do
    member do
      get :borrow_form
      post :borrow
    end
  end

  namespace :api do
    namespace :v1 do
      resources :venues, only: [:index, :show]
      resources :bookings, only: [:index, :show, :create]
      resources :equipment, only: [:index, :show]
    end
  end

  root "sessions#new"
  mount ActionCable.server => "/cable"
end
