Rails.application.routes.draw do
  root 'locations#index'

  get 'locations/return_nearby_locations'
  get 'locations/secret'
  get 'locations/twilio_test'
  get 'locations/list'
  get 'locations/mylocations'
  get 'locations/:id/save', to: 'locations#save', as: :save

  # custom devise resource
  devise_for :users

  resources :locations
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
