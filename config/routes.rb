Rails.application.routes.draw do
  root 'locations#index'

  get 'locations/return_nearby_locations'
  get 'locations/map_view'
  get 'locations/mylocations'
  get 'locations/:id/save', to: 'locations#save', as: :save
  get 'locations/:id/watch', to: 'locations#watch', as: :watch
  get 'locations/:user_id/unwatch', to: 'locations#unwatch_all', as: :unwatch_all

  # custom devise resource
  devise_for :users, controllers: { registrations: :registrations }

  resources :locations
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
