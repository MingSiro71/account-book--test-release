Rails.application.routes.draw do
  get '/signup', to: 'users#new'
  post '/signup', to: 'users#create'  
  resources :users, :only => [:index, :update]
  get '/division', to: 'static_pages#division'
  root 'static_pages#home'
end
