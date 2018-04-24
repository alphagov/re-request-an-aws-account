Rails.application.routes.draw do
  get '/', to: 'index#index'
  post '/', to: 'index#post'
end
