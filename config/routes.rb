Rails.application.routes.draw do
  get 'answers/create'
  get 'answers/update'
  get 'users/show'
  devise_for :users
  root to: 'pages#home'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
