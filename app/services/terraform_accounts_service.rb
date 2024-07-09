class TerraformAccountsService
  AWS_ROOT_ACCOUNTS_EMAIL_FORMAT = 'aws-root-accounts+%s@digital.cabinet-office.gov.uk'

  def initialize users_terraform
    @users_terraform_orig = JSON.parse users_terraform
    @users_terraform = JSON.parse users_terraform
  end

  def add_account(account_name, tags)
    accounts = @users_terraform.fetch 'resource'
    resource_names = accounts.map {|u| u['aws_organizations_account'].keys }.flatten

    if resource_names.include? account_name
      raise Errors::AccountAlreadyExistsError.new account_name
    end

    tags.each {| name, value |
    new_value = value
      new_value = new_value.gsub("&", "AND")
      new_value = new_value.gsub(/[^ A-Za-z0-9.:+=@_\/\-]/, '')
      tags[name] = new_value
    }
    accounts.push('aws_organizations_account' => {
      account_name => {
        'name': account_name,
        'email': AWS_ROOT_ACCOUNTS_EMAIL_FORMAT % truncate_account_name_for_email(account_name),
        'role_name': 'bootstrap',
        'iam_user_access_to_billing': 'ALLOW',
        'tags': tags,
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
