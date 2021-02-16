class UserController < ApplicationController
  def user
    @form = UserForm.new({})
  end

  def post
    form_params = params
                    .fetch('user_form', {})
                    .permit(:email_list).to_h
    @form = UserForm.new(form_params)
    return render :user if @form.invalid?

    requester_email = session.fetch('email')
    email_list = @form.email_list

    begin
      pull_request_url = GithubService.new.create_new_user_pull_request(email_list, requester_email)

      session['pull_request_url'] = pull_request_url

      notify_service = NotifyService.new
      notify_service.new_user_email_support(email_list, requester_email, pull_request_url)
      notify_service.new_user_email_user(email_list, requester_email, pull_request_url)

      redirect_to confirmation_user_path
    rescue EmailTooLongError => e
      @form.errors.add 'email_list', 'contains email address over 64 characters in length - see if you can get the user an alias'
      log_error 'Email provided was too long', e
      return render :user
    rescue StandardError => e
      session['pull_request_url'] = 'error-creating-pull-request'
      log_error 'Failed to raise new user PR', e
      redirect_to confirmation_user_path
    end
  end
end
