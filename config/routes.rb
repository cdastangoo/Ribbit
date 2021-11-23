Rails.application.routes.draw do
  root 'static_pages#home'
  get '/about', to: 'static_pages#about'
  get '/privacy', to: 'static_pages#privacy'
  get '/terms', to: 'static_pages#terms'
  get '/signup', to: 'users#new'
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'
  # resources :users, except: [:show]
  # get '/users/:name', to: 'users#show'
  resources :users do
    member do
      get :following, :followers
    end
  end
  resources :account_activations, only: [:edit]
  resources :password_resets, only: [:new, :create, :edit, :update]
  resources :posts, only: [:create, :destroy]
  resources :relationships, only: [:create, :destroy]
end
