Rails.application.routes.draw do
  get  "login",  to: "sessions#new"
  post "login",  to: "sessions#create"
  delete "logout", to: "sessions#destroy"

  get "dashboard", to: "dashboards#show"
  get "admin",     to: "admin#show"

  get "home/index"

  root "home#index"
end
