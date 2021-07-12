class PasswordResetForm
  include ActiveModel::Model
end

class ResetPasswordController < ApplicationController
  def reset_password
    @form = PasswordResetForm.new({})
  end

  def post
    @form = PasswordResetForm.new({})

    requester_name = session.fetch('name')
    requester_email = session.fetch('email')

    begin
      pull_request_url = GithubService.new.create_reset_user_email_pull_request(requester_name, requester_email)

      session['pull_request_url'] = pull_request_url

      notify_service = NotifyService.new
      notify_service.reset_password_email_support(requester_name, requester_email, pull_request_url)
      notify_service.reset_password_email_user(requester_name, requester_email, pull_request_url)

      redirect_to confirmation_reset_password_path
    rescue Errors::UserDoesntExistError => e
      @form.errors.add 'commit', "user #{e.message} does not exist"
      Errors::log_error 'User did not exist', e
      return render :reset_password
    rescue StandardError => e
      @form.errors.add 'commit', 'unknown error when opening pull request or sending email'
      Errors::log_error 'Failed to raise user password reset PR', e
      return render :reset_password
    end
  end
end
