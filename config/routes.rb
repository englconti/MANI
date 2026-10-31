Rails.application.routes.draw do
  # keep this on top, otherwise some errors will happen with log in!
  devise_for :users
  root to: 'pages#home'
  # ----------------------------------------------------------------

  resources :users, only: %i[show index]

  get "sem-vidas", to: "lives#show", as: :no_lives

  resources :questions, only: %i[show create] do
    resources :answers, only: %i[create]
  end
  resources :answers, only: %i[update]

  # Added for lesson resume page -----
  resources :lessons, only: [:show] do
    member do
      post :restart
      post :retry_wrong
    end
  end
  # ----------------------------------
  # Added for friendships ------------
  resources :friendships, only: %i[show create index destroy]
  # ----------------------------------

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
