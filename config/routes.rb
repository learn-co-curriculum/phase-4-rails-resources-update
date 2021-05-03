Rails.application.routes.draw do
  resources :birds, only: [:index, :show, :create]
end
