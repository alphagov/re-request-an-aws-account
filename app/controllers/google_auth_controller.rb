class GoogleAuthController < ApplicationController
  skip_before_action :authenticate

  def callback
    email = request.env['omniauth.auth']['info']['email']
    if email.end_with? '@digital.cabinet-office.gov.uk'
      session['email'] = email
      redirect_to account_details_path
    else
      redirect_to error_bad_email_path
    end
  end

  def error_bad_email
  end
end