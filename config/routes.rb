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


  resources :users
  resources :account_activations, only: [:edit]
<<<<<<< HEAD
  resources :password_resets, only:[:new, :create, :edit, :update]
=======
>>>>>>> chapter11-account-activation
end
