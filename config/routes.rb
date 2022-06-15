Rails.application.routes.draw do
  get 'friendships/new'
  get 'friendships/create'
  get 'friendships/index'
  get 'friendships/destroy'
  # keep this on top, otherwise some errors will happen with log in!
  devise_for :users
  root to: 'pages#home'
  # ----------------------------------------------------------------

  resources :users, only: %i[show index]

  resources :products, only: %i[index show]

  resources :questions, only: %i[show create] do
    resources :answers, only: %i[create]
  end
  resources :answers, only: %i[update]

  # Added for lesson resume page -----
  resources :lessons, only: [:show]
  # ----------------------------------
  # Added for friendships ------------
  resources :friendships, only: %i[show create index destroy]
  # ----------------------------------

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
