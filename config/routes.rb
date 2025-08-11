Rails.application.routes.draw do
  resources :birds, only: %i[index show create update]
  patch '/birds/:id/like', to: 'birds#increment_likes'
end
