Rails.application.routes.draw do
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

  root "sessions#new"
  mount ActionCable.server => "/cable"
end
