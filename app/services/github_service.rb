require 'octokit'

class GithubService
  def initialize
    if ENV.has_key? 'GITHUB_PERSONAL_ACCESS_TOKEN'
      @client = Octokit::Client.new(access_token: ENV['GITHUB_PERSONAL_ACCESS_TOKEN'])
    end
  end

  def create_new_account_pull_request(account_name, account_description, programme, email, admin_users, tags, host)
    unless @client
      Errors::log_error 'No GITHUB_PERSONAL_ACCESS_TOKEN set. Skipping pull request.'
      return nil
    end

    new_branch_name = 'new-aws-account-' + account_name
    github_repo = 'alphagov/aws-billing-account'
    master = @client.commit(github_repo, 'master')
    create_branch github_repo, new_branch_name, master.sha

    for accounts_path in ['terraform/accounts.tf.json', 'terraform/accounts.tf'] do
      begin
        accounts_contents = @client.contents github_repo, path: accounts_path
      rescue Octokit::NotFound
        # allow a final failure to be detected
        accounts_path = nil
      else
        break
      end
    end
    unless accounts_path
      Errors::log_error "Couldn't locate accounts terraform file."
      return nil
    end

    name = email.split('@').first.split('.').map { |name| name.capitalize }.join(' ')
    terraform_accounts_service = TerraformAccountsService.new(Base64.decode64(accounts_contents.content))
    new_account_terraform = terraform_accounts_service.add_account(account_name, tags)
    account_description_quote = account_description.split(/\r?\n/).map {|desc| "> #{desc}"}.join("\n")
    @client.update_contents(
      github_repo,
      accounts_path,
      "Add new AWS account for #{programme}: #{account_name}

Description:
#{account_description_quote}

Co-authored-by: #{name} <#{email}>",
      accounts_contents.sha,
      new_account_terraform,
      branch: new_branch_name
    )
    @client.create_pull_request(
      github_repo,
      'master',
      new_branch_name,
      "Add new AWS account for #{programme}: #{account_name}",
      "Account requested using #{host} by #{email}

Description:
#{account_description_quote}

Once the account is created, the following users should be granted access to the admin role:

```
#{admin_users}
```"
    ).html_url
  end

  def create_new_user_pull_request(email_list, requester_email, host)
    unless @client
      Errors::log_error 'No GITHUB_PERSONAL_ACCESS_TOKEN set. Skipping pull request.'
      return nil
    end

    github_repo = 'alphagov/aws-user-management-account-users'
    users_path = 'terraform/gds_users.tf.json'
    groups_path = 'terraform/iam_crossaccountaccess_members.tf.json'

    users_contents = @client.contents github_repo, path: users_path
    groups_contents = @client.contents github_repo, path: groups_path

    terraform_users_service = TerraformUsersService.new Base64.decode64(users_contents.content), Base64.decode64(groups_contents.content)
    new_users_contents = terraform_users_service.add_users(email_list)
    new_groups_contents = terraform_users_service.add_users_to_group(email_list)

    first_part_of_new_email_address = email_list.split('@').first

    if multiple_users?(email_list)
      commit_message_title = "Add AWS user #{first_part_of_new_email_address} and friends"
    else
      commit_message_title = "Add AWS user #{first_part_of_new_email_address}"
    end

    new_branch_name = 'new-aws-user-' + first_part_of_new_email_address.split('.').join('-') + ('-and-friends' if multiple_users?(email_list)).to_s
    create_branch github_repo, new_branch_name, @client.commit(github_repo, 'master').sha
    name = requester_email.split('@').first.split('.').map { |name| name.capitalize }.join(' ')
    @client.update_contents(
      github_repo,
      users_path,
      "#{commit_message_title}

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
      commit_message_title,
      "Requested using #{host} by #{requester_email}

  #{email_list}"
      ).html_url      github_repo,
      groups_path,
      "Remove users from crossaccountaccess group

#{email_list}

Co-authored-by: #{requester_name} <#{requester_email}>",
      groups_contents.sha,
      new_groups_contents,
      branch: new_branch_name
    )
    @client.create_pull_request(
      github_repo,
      'master',
      new_branch_name,
      commit_message_title,
      "Requested using #{host} by #{requester_email}

      #{email_list}"
    ).html_url
  end

  def create_reset_user_email_pull_request(requester_name, requester_email, host)
    unless @client
      Errors::log_error 'No GITHUB_PERSONAL_ACCESS_TOKEN set. Skipping pull request.'
      return nil
    end

    github_repo = 'alphagov/aws-user-management-account-users'

    users_path = 'terraform/gds_users.tf.json'
    groups_path = 'terraform/iam_crossaccountaccess_members.tf.json'
    users_contents = @client.contents github_repo, path: users_path
    groups_contents = @client.contents github_repo, path: groups_path
    terraform_users_service = TerraformUsersService.new Base64.decode64(users_contents.content), Base64.decode64(groups_contents.content)
    terraform_users_service.assert_user_exists(requester_email)

    password_reset_path = 'mgmt/password-reset-emails.txt'

    password_reset_contents = @client.contents github_repo, path: password_reset_path

    new_password_reset_contents = "#{requester_email}\n"

    first_part_of_requester_email_address = requester_email.split('@').first

    new_branch_name = 'reset-aws-user-password-' + first_part_of_requester_email_address.split('.').join('-')
    create_branch github_repo, new_branch_name, @client.commit(github_repo, 'master').sha

    commit_message_title = "Reset password of AWS user #{requester_name}"

    @client.update_contents(
      github_repo,
      password_reset_path,
      "#{commit_message_title}

Co-authored-by: #{requester_name} <#{requester_email}>",
      password_reset_contents.sha,
      new_password_reset_contents,
      branch: new_branch_name
    )
    @client.create_pull_request(
      github_repo,
      'master',
      new_branch_name,
      commit_message_title,
      "Requested using #{host} by #{requester_name}"
    ).html_url
  end

  private

  def create_branch(repo, branch_name, sha)
    begin
      @client.create_ref repo, 'heads/' + branch_name, sha
    rescue Octokit::UnprocessableEntity => e
      Errors::log_error "Failed to create branch #{branch_name}. Perhaps there's already a branch with that name?", e
    end
  end

  def multiple_users?(email_list)
    email_list.split('@').size > 2
  end
end
