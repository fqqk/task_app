Rails.application.routes.draw do
  root to: "home#index"
  devise_for :users
  mount LetterOpenerWeb::Engine, at: '/letter_opener' if Rails.env.development?
end
