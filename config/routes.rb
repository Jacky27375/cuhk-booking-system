Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  get  "login",  to: "sessions#new"
  post "login",  to: "sessions#create"
  delete "logout", to: "sessions#destroy"

  get  "signup", to: "registrations#new"
  post "signup", to: "registrations#create"
  get  "signup/verify", to: "registrations#verify", as: :signup_verify
  post "signup/verify", to: "registrations#verify_code", as: :signup_verify_code
  post "signup/resend_code", to: "registrations#resend_code", as: :signup_resend_code

  get  "password_reset", to: "password_resets#new"
  post "password_reset", to: "password_resets#create"
  get  "password_reset/verify", to: "password_resets#verify", as: :password_reset_verify
  post "password_reset/verify", to: "password_resets#update", as: :password_reset_verify_code
  post "password_reset/resend_code", to: "password_resets#resend_code", as: :password_reset_resend_code

  get "dashboard", to: "dashboards#show"
  get "approval_dashboard", to: "dashboards#approvals"
  get "admin",     to: "admin#show"
  get "analytics", to: "analytics#show"

  namespace :admin do
    resources :users, only: [:index, :destroy] do
      member do
        patch :reset_root_staff_password
      end
    end
  end

  resources :staff_accounts, only: [:index, :new, :create]

  resources :venue_requests, only: [:index, :show, :new, :create] do
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
