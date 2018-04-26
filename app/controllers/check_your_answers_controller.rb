class CheckYourAnswersController < ApplicationController
  def check_your_answers
    @answers = session['form'].with_indifferent_access
  end

  def post
    all_params = session['form']
    pr_url = create_pull_request(JSON.pretty_generate(all_params))
    card_id = Trello::Card.create(
      list_id: '5ade08f50b5895b033065f71',
      name: "#{all_params['account_name']} (#{all_params['programme']})",
      desc: "New AWS account requested by #{session['email']}\n\nA pull request has been generated for you: #{pr_url}"
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