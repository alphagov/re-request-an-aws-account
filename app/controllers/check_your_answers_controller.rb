class CheckYourAnswersController < ApplicationController
  def check_your_answers
    @answers = session.fetch('form', {}).with_indifferent_access
  end

  def post
    all_params = session['form']

    account_name = all_params['account_name']
    programme = all_params['programme']
    email = session['email']

    pull_request_url = GithubService.new.create_new_account_pull_request(JSON.pretty_generate(all_params), account_name, programme, email)

    trello_url = TrelloService.create_new_aws_account_card(email, account_name, programme, pull_request_url)
    card_id = trello_url ? trello_url.split('/').last : nil # Hack - ruby-trello doesn't expose shortLink

    session['card_id'] = card_id

    notify_service = NotifyService.new
    notify_service.new_account_email_support(account_name: account_name, programme: programme, email: email, trello_url: trello_url, pull_request_url: pull_request_url)
    notify_service.new_account_email_user email, account_name, card_id

    redirect_to confirmation_path
  end
end