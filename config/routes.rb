Rails.application.routes.draw do
  
  resources :users, only: [:show]
  resources :questions, only: [:show, :create]
  resources :answers, only: [:create, :update]
  
  devise_for :users
  root to: 'pages#home'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
