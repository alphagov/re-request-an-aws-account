require 'test_helper'

INITIAL_TERRAFORM = <<EOTERRAFORM
{
  "resource": [
    {
      "aws_iam_user": {
        "uncle_bulgaria": {
          "name": "uncle.bulgaria@digital.cabinet-office.gov.uk",
          "force_destroy": true
        }
      }
    },
    {
      "aws_iam_user": {
        "tobermory": {
          "name": "tobermory@digital.cabinet-office.gov.uk",
          "force_destroy": true
        }
      }
    },
    {
      "aws_iam_user": {
        "bungo": {
          "name": "bungo@digital.cabinet-office.gov.uk",
          "force_destroy": true
        }
      }
    }
  ]
}
EOTERRAFORM

class TerraformUsersServiceTest < ActiveSupport::TestCase
  test 'Adds a user' do
    terraform_users_service = TerraformUsersService.new(INITIAL_TERRAFORM)
    result = terraform_users_service.add_user 'test.aws-user@example.com'

    assert_match /"test_aws-user"/, result
    assert_match /"test.aws-user@example.com"/, result
    assert_equal result, JSON.pretty_generate(JSON.parse(result))
  end

  test 'Raises if the same user is added twice' do
    terraform_users_service = TerraformUsersService.new(INITIAL_TERRAFORM)
    assert_raises {
      terraform_users_service.add_user 'bungo@digital.cabinet-office.gov.uk'
    }
  end

  test 'Resources are sorted' do
    terraform_users_service = TerraformUsersService.new(INITIAL_TERRAFORM)
    result = terraform_users_service.add_user 'test.aws-user@example.com'
    users = JSON.parse(result)
    resource_names = users.fetch('resource').map {|u| u['aws_iam_user'].keys }.flatten

    assert_equal resource_names, resource_names.sort
  end
end
