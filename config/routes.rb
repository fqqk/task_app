Rails.application.routes.draw do
  root to: "tasks#index"
  resources :tasks do
    get :assign, on: :member
    patch :update_assign, on: :member
  end
  resources :mytasks, only:[:index]
  devise_for :users
  mount LetterOpenerWeb::Engine, at: '/letter_opener' if Rails.env.development?
end
