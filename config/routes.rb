# config/routes.rb
Rails.application.routes.draw do
  root 'api_forms#index'

  # Ensure that the routes for edit and update are included
  resources :api_forms, only: [:index, :edit, :update]
end
