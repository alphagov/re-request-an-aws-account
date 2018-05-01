require 'octokit'

class GithubService
  def initialize
    if ENV.has_key? 'GITHUB_PERSONAL_ACCESS_TOKEN'
      @client = Octokit::Client.new(access_token: ENV['GITHUB_PERSONAL_ACCESS_TOKEN'])
    end
  end

  def create_new_account_pull_request(new_value, account_name, programme, email)
    unless @client
      Rails.logger.warn 'Warning: no GITHUB_PERSONAL_ACCESS_TOKEN set. Skipping pull request.'
      return nil
    end

    new_branch_name = 'new-aws-account-' + account_name
    master = @client.commit('richardTowers/re-example-repo', 'master')
    create_branch 'richardTowers/re-example-repo', new_branch_name, master.sha

    contents = @client.contents 'richardTowers/re-example-repo', path: 'terraform/example/scratch.json'

    name = email.split('@').first.split('.').map { |name| name.capitalize }.join(' ')
    @client.update_contents(
      'richardTowers/re-example-repo',
      'terraform/example/scratch.json',
      "Add new AWS account for #{programme}: #{account_name}

Co-authored-by: #{name} <#{email}>",
      contents.sha,
      new_value,
      branch: new_branch_name
    )
    @client.create_pull_request(
      'richardTowers/re-example-repo',
      'master',
      new_branch_name,
      "Add new AWS account for #{programme}: #{account_name}",
      "Account requested using gds-request-an-aws-account.cloudapps.digital by #{email}"
    ).html_url
  end

  def create_new_user_pull_request(email_list, requester_email)
    unless @client
      Rails.logger.warn 'Warning: No GITHUB_PERSONAL_ACCESS_TOKEN set. Skipping pull request.'
      return nil
    end

    github_repo = 'alphagov/aws-user-management-account-users'
    users_path = 'terraform/gds_users.tf'
    groups_path = 'terraform/iam_crossaccountaccess_members.tf'

    users_contents = @client.contents github_repo, path: users_path
    groups_contents = @client.contents github_repo, path: groups_path

    terraform_users_service = TerraformUsersService.new Base64.decode64(users_contents.content), Base64.decode64(groups_contents.content)
    new_users_contents = terraform_users_service.add_users(email_list)
    new_groups_contents = terraform_users_service.add_users_to_group(email_list)


    new_branch_name = 'new-aws-user-' + email_list.split('@').first.split('.').join('-') + ('-and-friends' if email_list.split('@').size > 2).to_s
    create_branch github_repo, new_branch_name, @client.commit(github_repo, 'master').sha
    name = requester_email.split('@').first.split('.').map { |name| name.capitalize }.join(' ')
    @client.update_contents(
      github_repo,
      users_path,
      "Add new AWS users

#{email_list}

Co-authored-by: #{name} <#{requester_email}>",
      users_contents.sha,
      new_users_contents,
      branch: new_branch_name
    )
    @client.update_contents(
      github_repo,
      groups_path,
      "Add users to crossaccountaccess group

#{email_list}

Co-authored-by: #{name} <#{requester_email}>",
      groups_contents.sha,
      new_groups_contents,
      branch: new_branch_name
    )
    @client.create_pull_request(
      github_repo,
      'master',
      new_branch_name,
      "Add new users to AWS",
      "Account requested using gds-request-an-aws-account.cloudapps.digital by #{requester_email}

#{email_list}"
    ).html_url
  end

private

  def create_branch(repo, branch_name, sha)
    begin
      @client.create_ref repo, 'heads/' + branch_name, sha
    rescue Octokit::UnprocessableEntity
      puts "Failed to create branch #{branch_name}. Perhaps there's already a branch with that name?"
    end
  end
end