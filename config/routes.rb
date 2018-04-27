Rails.application.routes.draw do
  get '/', to: 'index#index', as: :index
  post '/', to: 'index#post'

  get '/user', to: 'user#user', as: :user
  post '/user', to: 'user#post'

  get '/account-details', to: 'account_details#account_details', as: :account_details
  post '/account-details', to: 'account_details#post'

  get '/programme', to: 'programme#programme', as: :programme
  post '/programme', to: 'programme#post'

  get '/administrators', to: 'administrators#administrators', as: :administrators
  post '/administrators', to: 'administrators#post'

  get '/check-your-answers', to: 'check_your_answers#check_your_answers', as: :check_your_answers
  post '/check-your-answers', to: 'check_your_answers#post'

  get '/confirmation', to: 'confirmation#confirmation', as: :confirmation
  post '/confirmation', to: 'confirmation#post'

  get '/auth/google_oauth2/callback', to: 'google_auth#callback'
  get '/auth/google_oauth2/error/bad-email', to: 'google_auth#error_bad_email', as: :error_bad_email
end
