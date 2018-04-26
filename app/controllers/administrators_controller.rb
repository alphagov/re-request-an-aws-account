require 'trello'
require 'octokit'

Trello.configure do |config|
  config.developer_public_key = ENV['TRELLO_DEVELOPER_PUBLIC_KEY']
  config.member_token = ENV['TRELLO_MEMBER_TOKEN']
end

class AdministratorsController < ApplicationController
  def administrators
    @form = RequestAnAwsAccountForm.new({})
  end

  def post
    form_params = params.fetch('request_an_aws_account_form', {})
    all_params = session.fetch('form', {}).merge form_params.permit(
      :account_name,
      :programme,
      :is_production,
      :admin_users
    )
    @form = RequestAnAwsAccountForm.new(all_params.with_indifferent_access)
    session['form'] = all_params

    # This is the last controller, so we should do the side effects now.
    # Initially let's just stick a card in trello
    pr_url = create_pull_request(JSON.pretty_generate(all_params))
    card_id = Trello::Card.create(
      list_id: '5ade08f50b5895b033065f71',
      name: "#{@form.account_name} (#{@form.programme})",
      desc: "New AWS account requested\n\nA pull request has been generated for you: #{pr_url}"
    ).short_url.split('/').last # Hack - ruby-trello doesn't expose shortLink

    session['card_id'] = card_id

    redirect_to confirmation_path
  end

  def create_pull_request(new_value)
    new_branch_name = 'bau-test-octokit-' + SecureRandom.alphanumeric(6)
    client = Octokit::Client.new(access_token: ENV['GITHUB_PERSONAL_ACCESS_TOKEN'])
    master = client.commit('richardTowers/re-example-repo', 'master')
    client.create_ref 'richardTowers/re-example-repo', 'heads/' + new_branch_name, master.sha

    contents = client.contents 'richardTowers/re-example-repo', path: 'terraform/example/scratch.json'
    client.update_contents(
      'richardTowers/re-example-repo',
      'terraform/example/scratch.json',
      'Updating content with octokit',
      contents.sha,
      new_value,
      branch: new_branch_name
    )
    client.create_pull_request(
      'richardTowers/re-example-repo',
      'master',
      new_branch_name,
      'Test a PR from octokit',
      'Pair: @richardTowers'
    ).html_url
  end
end