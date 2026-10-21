Rails.application.routes.draw do
  # set the root to the home page
  root "pages#home"

  # use devise to handle user authentication
  devise_for :users, controllers: { registrations: "users/registrations" }

  # user profiles are read-only to prevent
  # users changing other users' data
  resources :users, only: %i[index show], path: "readers"

  # search Open Library and add a result to the catalogue
  get  "books/add", to: "book_imports#new",    as: :new_book_import
  post "books/add", to: "book_imports#create", as: :book_import

  resources :books
  resources :user_books, only: %i[create update destroy]
  resources :recommendations, only: :index

  # admin dashboard
  namespace :admin do
    root "dashboard#index"
    resources :users, only: %i[update destroy]
    resource :covers, only: :create
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
end
