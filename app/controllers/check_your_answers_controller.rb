require 'notifications/client'

class CheckYourAnswersController < ApplicationController
  def check_your_answers
    @answers = session.fetch('form', {}).with_indifferent_access
  end

  def post
    all_params = session['form']

    account_name = all_params['account_name']
    programme = all_params['programme']
    email = session['email']

    pull_request_url = GithubService.create_pull_request(JSON.pretty_generate(all_params), account_name, programme, email)

    trello_url = TrelloService.create_new_aws_account_card(email, account_name, programme, pull_request_url)
    card_id = trello_url.split('/').last # Hack - ruby-trello doesn't expose shortLink

    session['card_id'] = card_id

    send_email_to_reliability_engineering(
      account_name: account_name,
      programme: programme,
      email: email,
      trello_url: trello_url,
      pull_request_url: pull_request_url
    )

    send_confirmation_email_to_user email, account_name, card_id

    redirect_to confirmation_path
  end

  def send_email_to_reliability_engineering(personalisation)
    client = Notifications::Client.new(ENV.fetch 'NOTIFY_API_KEY')
    client.send_email(
      email_address: 'richard.towers@digital.cabinet-office.gov.uk',
      template_id: '95358639-a3d0-4f27-baf9-50bf530891a8',
      personalisation: personalisation
    )
  end

  def send_confirmation_email_to_user(email, account_name, card_id)
    client = Notifications::Client.new(ENV.fetch 'NOTIFY_API_KEY')
    client.send_email(
      email_address: email,
      template_id: '4db8b8a6-1486-44e3-9bf4-572d64be7881',
      personalisation: {
        account_name: account_name,
        card_id: card_id
      }
    )
  end
end