Rails.application.routes.draw do
  root to: "home#index"
  devise_for :users, :controllers => {
    :confirmations => 'users/confirmations',
    :registrations => 'users/registrations',
    :sessions => 'users/sessions',
    :passwords => 'users/passwords'
   }
  mount LetterOpenerWeb::Engine, at: '/letter_opener' if Rails.env.development?
end
