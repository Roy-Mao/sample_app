Rails.application.routes.draw do
  #get 'password_resets/new'

  #get 'password_resets/edit'

  #get 'sessions/new'

  #get 'users/new'

  #get 'static_pages/home'
  get '/help', to: 'static_pages#help'
  #get 'static_pages/help'
  get '/about', to: 'static_pages#about'
  #get 'static_pages/about'
  #get 'static_pages/contact'
  get '/contact', to: 'static_pages#contact'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get '/signup', to: 'users#new'
  post '/signup', to: 'users#create'

  root 'static_pages#home'
  #root 'sessions#new'

  get '/login', to:'sessions#new'
  post '/login', to:'sessions#create'
  delete '/logout', to:'sessions#destroy'

  # There is the corresponding action to the route /users. The action is the users/index
  # There is no such action like index for the password_reset resource
  resources :users do
    member do
      get :following, :followers
    end
  end


  resources :account_activations, only: [:edit]
  resources :password_resets, only:[:new, :create, :edit, :update]
  resources :microposts, only:[:create, :destroy]

  resources :relationships, only:[:create, :destroy]
end
