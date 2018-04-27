require 'trello'
require 'octokit'
require 'notifications/client'

Trello.configure do |config|
  config.developer_public_key = ENV.fetch 'TRELLO_DEVELOPER_PUBLIC_KEY'
  config.member_token = ENV.fetch 'TRELLO_MEMBER_TOKEN'
end

class CheckYourAnswersController < ApplicationController
  def check_your_answers
    @answers = session.fetch('form', {}).with_indifferent_access
  end

  def post
    all_params = session['form']

    account_name = all_params['account_name']
    programme = all_params['programme']
    email = session['email']

    pull_request_url = create_pull_request(JSON.pretty_generate(all_params), account_name, programme, email)

    trello_url = Trello::Card.create(
      list_id: '5ade08f50b5895b033065f71',
      name: "#{account_name} (#{programme})",
      desc: "New AWS account requested by #{email}\n\nA pull request has been generated for you: #{pull_request_url}"
    ).short_url

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

  def create_pull_request(new_value, account_name, programme, email)
    new_branch_name = 'new-aws-account-' + account_name
    client = Octokit::Client.new(access_token: ENV.fetch('GITHUB_PERSONAL_ACCESS_TOKEN'))
    master = client.commit('richardTowers/re-example-repo', 'master')
    client.create_ref 'richardTowers/re-example-repo', 'heads/' + new_branch_name, master.sha

    contents = client.contents 'richardTowers/re-example-repo', path: 'terraform/example/scratch.json'

    name = email.split('@').first.split('.').map { |name| name.capitalize }.join(' ')
    client.update_contents(
      'richardTowers/re-example-repo',
      'terraform/example/scratch.json',
      "Add new AWS account for #{programme}: #{account_name}

Co-authored-by: #{name} <#{email}>",
      contents.sha,
      new_value,
      branch: new_branch_name
    )
    client.create_pull_request(
      'richardTowers/re-example-repo',
      'master',
      new_branch_name,
      "Add new AWS account for #{programme}: #{account_name}",
      "Account requested using gds-request-an-aws-account.cloudapps.digital by #{email}"
    ).html_url
  end
end