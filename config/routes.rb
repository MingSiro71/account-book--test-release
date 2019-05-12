Rails.application.routes.draw do
  get 'experiments/new'
  get 'sessions/new'
  get '/signup', to: 'users#new'
  post '/signup', to: 'users#create'  
  resources :users, :only => [:index, :update]
  get '/division', to: 'static_pages#division'
  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'
  resources :account_activations, only: [:edit]
  resources :password_resets,     only: [:new, :create, :edit, :update]
  root 'static_pages#home'
end
