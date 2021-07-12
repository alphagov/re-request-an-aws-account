class RemoveUserController < ApplicationController
  def remove_user
    @form = UserForm.new({})
  end

  def post
    form_params = params
                    .fetch('user_form', {})
                    .permit(:email_list).to_h
    @form = UserForm.new(form_params)
    return render :remove_user if @form.invalid?

    requester_email = session.fetch('email')
    email_list = @form.email_list

    begin
      pull_request_url = GithubService.new.create_remove_user_pull_request(email_list, requester_email)

      session['pull_request_url'] = pull_request_url

      notify_service = NotifyService.new
      notify_service.remove_user_email_support(email_list, requester_email, pull_request_url)
      notify_service.remove_user_email_user(email_list, requester_email, pull_request_url)

      redirect_to confirmation_remove_user_path
    rescue Errors::UserDoesntExistError => e
      @form.errors.add 'email_list', "user #{e.message} does not exist"
      Errors::log_error 'User did not exist', e
      return render :remove_user
    rescue StandardError => e
      @form.errors.add 'email_list', 'unknown error when opening pull request or sending email'
      Errors::log_error 'Failed to raise user removal PR or send email', e
      return render :remove_user
    end
  end
end
