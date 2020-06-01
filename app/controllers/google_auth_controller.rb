class GoogleAuthController < ApplicationController
  skip_before_action :authenticate

  def callback
    email = request.env['omniauth.auth']['info']['email']

    if EmailValidator.email_is_allowed?(email)
      session['email'] = email
      session['name'] = request.env['omniauth.auth']['info']['name']

      redirect_to index_path
    else
      redirect_to error_bad_email_path
    end
  end

  def error_bad_email
  end
end
