Rails.application.routes.draw do
  get '/', to: 'index#index', as: :index
  post '/', to: 'index#post'

  get '/account-details', to: 'account_details#account_details', as: :account_details
  post '/account-details', to: 'account_details#post'

  get '/programme', to: 'programme#programme', as: :programme
  post '/programme', to: 'programme#post'

  get '/administrators', to: 'administrators#administrators', as: :administrators
  post '/administrators', to: 'administrators#post'

  get '/confirmation', to: 'confirmation#confirmation', as: :confirmation
  post '/confirmation', to: 'confirmation#post'
end
