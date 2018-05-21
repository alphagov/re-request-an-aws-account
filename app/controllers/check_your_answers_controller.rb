class CheckYourAnswersController < ApplicationController
  def check_your_answers
    @answers = session.fetch('form', {}).with_indifferent_access
  end

  def post
    all_params = session['form']

    account_name = all_params['account_name']
    programme = all_params['programme']
    email = session['email']

    pull_request_url = GithubService.new.create_new_account_pull_request(account_name, programme, email)

    session['pull_request_url'] = pull_request_url

    notify_service = NotifyService.new
    notify_service.new_account_email_support(account_name: account_name, programme: programme, email: email, pull_request_url: pull_request_url)
    notify_service.new_account_email_user email, account_name, pull_request_url

    redirect_to confirmation_account_path
  end
end