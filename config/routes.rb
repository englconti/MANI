Rails.application.routes.draw do
  resources :users, only: [:show]

  resources :questions, only: %i[show create] do
    resources :answers, only: %i[create]
  end
  resources :answers, only: %i[update]

  devise_for :users
  root to: 'pages#home'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
