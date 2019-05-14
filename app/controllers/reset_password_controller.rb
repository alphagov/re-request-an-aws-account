class ResetPasswordController < ApplicationController
  def reset_password
    @form = UserForm.new({})
  end

  def post
    requester_name = session.fetch('name')
    requester_email = session.fetch('email')

    pull_request_url = GithubService.new.create_reset_user_email_pull_request(requester_name, requester_email) || 'error-creating-pull-request'

    session['pull_request_url'] = pull_request_url

    notify_service = NotifyService.new
    notify_service.reset_password_email_support(requester_name, requester_email, pull_request_url)
    notify_service.reset_password_email_user(requester_name, requester_email, pull_request_url)

    redirect_to confirmation_reset_password_path
  end
end
