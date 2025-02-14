Rails.application.routes.draw do
  root "api_forms#index"

  # Adding routes for new and create actions
  resources :api_forms, only: [ :index, :edit, :update, :new, :create ]
end
