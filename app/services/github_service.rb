require 'octokit'

class GithubService
  def self.create_pull_request(new_value, account_name, programme, email)
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