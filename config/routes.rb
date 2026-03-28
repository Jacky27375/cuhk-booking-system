Rails.application.routes.draw do
  get  "login",  to: "sessions#new"
  post "login",  to: "sessions#create"
  delete "logout", to: "sessions#destroy"

  get "dashboard", to: "dashboards#show"
  get "approval_dashboard", to: "dashboards#approvals"
  get "admin",     to: "admin#show"

  resources :bookings do
    member do
      patch :approve
      patch :reject
    end
    collection do
      get :my
    end
  end
  resources :venues
  get "home/index"

  resources :equipments

  root "sessions#new"
  mount ActionCable.server => "/cable"
end
