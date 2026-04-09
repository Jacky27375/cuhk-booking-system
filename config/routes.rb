Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  get  "login",  to: "sessions#new"
  post "login",  to: "sessions#create"
  delete "logout", to: "sessions#destroy"

  get  "signup", to: "registrations#new"
  post "signup", to: "registrations#create"

  get "dashboard", to: "dashboards#show"
  get "approval_dashboard", to: "dashboards#approvals"
  get "admin",     to: "admin#show"
  get "analytics", to: "analytics#show"

  resources :staff_accounts, only: [:index, :new, :create]

  resources :venue_requests, only: [:index, :new, :create] do
    member do
      patch :approve
      patch :reject
    end
  end

  resources :bookings do
    member do
      patch :approve
      patch :reject
      patch :cancel
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
