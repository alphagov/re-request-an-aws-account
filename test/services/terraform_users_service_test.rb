require 'test_helper'

INITIAL_USERS_TERRAFORM = <<EOTERRAFORM
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

INITIAL_GROUPS_TERRAFORM = <<EOTERRAFORM
{
  "resource": {
    "aws_iam_group_membership": {
      "crossaccountaccess-members": {
        "name": "crossaccountaccess-membership",
        "users": [
          "${aws_iam_user.uncle_bulgaria.name}",
          "${aws_iam_user.tobermory.name}",
          "${aws_iam_user.bungo.name}"
        ],
        "group": "CrossAccountAccess"
      }
    }
  }
}
EOTERRAFORM

class TerraformUsersServiceTest < ActiveSupport::TestCase
  test 'Adds a user' do
    terraform_users_service = TerraformUsersService.new(INITIAL_USERS_TERRAFORM, INITIAL_GROUPS_TERRAFORM)
    result = terraform_users_service.add_users 'test.aws-user@example.com'

    assert_match /"test_aws-user"/, result
    assert_match /"test.aws-user@example.com"/, result
    assert_equal result, JSON.pretty_generate(JSON.parse(result)) + "\n"
  end

  test 'Strips rogue carriage returns' do
    terraform_users_service = TerraformUsersService.new(INITIAL_USERS_TERRAFORM, INITIAL_GROUPS_TERRAFORM)
    result = terraform_users_service.add_users "test.aws-user@example.com\r\n"

    assert_match /"test_aws-user"/, result
    assert_no_match /\\r/, result
    assert_no_match /\\n/, result
    assert_match /"test.aws-user@example.com"/, result

    assert_equal result, JSON.pretty_generate(JSON.parse(result)) + "\n"
  end

  test 'Adds multiple users' do
    terraform_users_service = TerraformUsersService.new(INITIAL_USERS_TERRAFORM, INITIAL_GROUPS_TERRAFORM)
    result = terraform_users_service.add_users "test.aws-user-one@example.com\ntest.aws-user-two@example.com,test.aws-user-three@example.com"

    assert_match /"test_aws-user-one"/, result
    assert_match /"test_aws-user-two"/, result
    assert_match /"test_aws-user-three"/, result
    assert_match /"test.aws-user-one@example.com"/, result
    assert_match /"test.aws-user-two@example.com"/, result
    assert_match /"test.aws-user-three@example.com"/, result
    assert_equal result, JSON.pretty_generate(JSON.parse(result)) + "\n"
  end

  test 'Raises if the no change to users in terraform' do
    terraform_users_service = TerraformUsersService.new(INITIAL_USERS_TERRAFORM, INITIAL_GROUPS_TERRAFORM)
    assert_raises {
      terraform_users_service.add_users 'bungo@digital.cabinet-office.gov.uk'
    }
  end

  test 'User resources are sorted' do
    terraform_users_service = TerraformUsersService.new(INITIAL_USERS_TERRAFORM, INITIAL_GROUPS_TERRAFORM)
    result = terraform_users_service.add_users 'test.aws-user@example.com'
    users = JSON.parse(result)
    resource_names = users.fetch('resource').map {|u| u['aws_iam_user'].keys }.flatten

    assert_equal resource_names, resource_names.sort
  end

  test 'Adds a user to a group' do
    terraform_users_service = TerraformUsersService.new(INITIAL_USERS_TERRAFORM, INITIAL_GROUPS_TERRAFORM)
    result = terraform_users_service.add_users_to_group 'test.aws-user@example.com'

    assert_match /"\$\{aws_iam_user.test_aws-user.name}"/, result
    assert_equal result, JSON.pretty_generate(JSON.parse(result)) + "\n"
  end

  test 'Adds multiple users to a group' do
    terraform_users_service = TerraformUsersService.new(INITIAL_USERS_TERRAFORM, INITIAL_GROUPS_TERRAFORM)
    result = terraform_users_service.add_users_to_group "test.aws-user-one@example.com\ntest.aws-user-two@example.com,test.aws-user-three@example.com"

    assert_match /"\$\{aws_iam_user.test_aws-user-one.name}"/, result
    assert_match /"\$\{aws_iam_user.test_aws-user-two.name}"/, result
    assert_match /"\$\{aws_iam_user.test_aws-user-three.name}"/, result
    assert_equal result, JSON.pretty_generate(JSON.parse(result)) + "\n"
  end

  test 'Raises if there are no changes to groups in terraform' do
    terraform_users_service = TerraformUsersService.new(INITIAL_USERS_TERRAFORM, INITIAL_GROUPS_TERRAFORM)
    assert_raises {
      terraform_users_service.add_users_to_group 'bungo@digital.cabinet-office.gov.uk'
    }
  end

  test 'Group members are sorted' do
    terraform_users_service = TerraformUsersService.new(INITIAL_USERS_TERRAFORM, INITIAL_GROUPS_TERRAFORM)
    result = terraform_users_service.add_users_to_group 'test.aws-user@example.com'
    terraform = JSON.parse(result)
    members = terraform['resource']['aws_iam_group_membership']['crossaccountaccess-members']['users']

    assert_equal members, members.sort
  end

  test 'Removes a user' do
    terraform_users_service = TerraformUsersService.new(INITIAL_USERS_TERRAFORM, INITIAL_GROUPS_TERRAFORM)
    result = terraform_users_service.remove_users 'uncle.bulgaria@digital.cabinet-office.gov.uk'

    assert_match /"tobermory"/, result
    assert_match /"bungo"/, result
    assert_no_match /"uncle_bulgaria"/, result
    assert_equal result, JSON.pretty_generate(JSON.parse(result)) + "\n"
  end

  test 'Removes a user from a group' do
    terraform_users_service = TerraformUsersService.new(INITIAL_USERS_TERRAFORM, INITIAL_GROUPS_TERRAFORM)
    result = terraform_users_service.remove_users_from_group 'uncle.bulgaria@digital.cabinet-office.gov.uk'

    assert_match /"\$\{aws_iam_user.tobermory.name}"/, result
    assert_match /"\$\{aws_iam_user.bungo.name}"/, result
    assert_no_match /"\$\{aws_iam_user.uncle_bulgaria.name}"/, result
    assert_equal result, JSON.pretty_generate(JSON.parse(result)) + "\n"
  end
end
