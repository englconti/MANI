Rails.application.routes.draw do
  # keep this on top, otherwise some errors will happen with log in!
  devise_for :users
  root to: 'pages#home'
  # ----------------------------------------------------------------

  resources :users, only: [:show]

  resources :products, only: %i[index show]

  resources :questions, only: %i[show create] do
    resources :answers, only: %i[create]
  end
  resources :answers, only: %i[update]


  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
