Rails.application.routes.draw do
  root 'locations#index'
  get 'locations/index'

  # custom devise resource
  devise_for :users

  # add routes that need to be protected in this block
  authenticate :user do
    get 'locations/secret'
  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
