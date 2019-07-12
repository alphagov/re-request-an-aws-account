class TerraformAccountsService
  AWS_ROOT_ACCOUNTS_EMAIL_FORMAT = 'aws-root-accounts+%s@digital.cabinet-office.gov.uk'

  def initialize users_terraform
    @users_terraform_orig = JSON.parse users_terraform
    @users_terraform = JSON.parse users_terraform
  end

  def add_account(account_name)
    accounts = @users_terraform.fetch 'resource'
    resource_names = accounts.map {|u| u['aws_organizations_account'].keys }.flatten

    if resource_names.include? account_name
      raise StandardError.new "Account #{account_name} is already present in the terraform."
    end

    accounts.push('aws_organizations_account' => {
      account_name => {
        'name': account_name,
        'email': AWS_ROOT_ACCOUNTS_EMAIL_FORMAT % truncate_account_name_for_email(account_name),
        'role_name': 'bootstrap',
        'iam_user_access_to_billing': 'ALLOW',
        'lifecycle': {
          'ignore_changes': [
            'tags'
          ]
        }
      }
    })

    accounts.sort_by! { |u| u['aws_organizations_account'].keys.first }

    JSON.pretty_generate(@users_terraform) + "\n"
  end

private

  def truncate_account_name_for_email account_name
    max_length = 64 - (AWS_ROOT_ACCOUNTS_EMAIL_FORMAT % [ '' ]).length
    groups = account_name.split('-').delete_if { |g| g == 'gds' }
    target_group_size = (max_length / groups.length) - 1
    if target_group_size < 2
      raise "account name has too many groups in it - can't make it short enough to fit AWS' rules"
    end
    groups.map { |g| g[0...target_group_size]}.join('-')
  end
end
