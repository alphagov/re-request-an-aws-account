require 'octokit'

class GithubService
  def self.create_new_account_pull_request(new_value, account_name, programme, email)
    new_branch_name = 'new-aws-account-' + account_name
    client = Octokit::Client.new(access_token: ENV.fetch('GITHUB_PERSONAL_ACCESS_TOKEN'))
    master = client.commit('richardTowers/re-example-repo', 'master')
    create_branch 'richardTowers/re-example-repo', client, new_branch_name, master.sha

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

  def self.create_new_user_pull_request(email, requester_email)
    github_repo = 'alphagov/aws-user-management-account-users'
    file_path = 'terraform/gds_users.tf'

    new_branch_name = 'new-aws-user-' + email.split('@').first.split('.').join('-')
    client = Octokit::Client.new(access_token: ENV.fetch('GITHUB_PERSONAL_ACCESS_TOKEN'))
    master = client.commit(github_repo, 'master')
    create_branch github_repo, client, new_branch_name, master.sha

    contents = client.contents github_repo, path: file_path

    terraform_users_service = TerraformUsersService.new Base64.decode64(contents.content)
    new_contents = terraform_users_service.add_user(email)

    name = requester_email.split('@').first.split('.').map { |name| name.capitalize }.join(' ')
    client.update_contents(
      github_repo,
      file_path,
      "Add new AWS user #{email}

Co-authored-by: #{name} <#{requester_email}>",
      contents.sha,
      new_contents,
      branch: new_branch_name
    )
    client.create_pull_request(
      github_repo,
      'master',
      new_branch_name,
      "Add new user to AWS #{email}",
      "Account requested using gds-request-an-aws-account.cloudapps.digital by #{requester_email}"
    ).html_url
  end

  def self.create_branch(repo, client, branch_name, sha)
    begin
      client.create_ref repo, 'heads/' + branch_name, sha
    rescue Octokit::UnprocessableEntity
      puts "Failed to create branch #{branch_name}. Perhaps there's already a branch with that name?"
    end
  end
end