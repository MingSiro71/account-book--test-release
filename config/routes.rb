Rails.application.routes.draw do
  get '/signup', to: 'users#new'
  get '/division', to: 'static_pages#division'
  root 'static_pages#home'
end
