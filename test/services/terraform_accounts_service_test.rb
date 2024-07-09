require 'test_helper'

INITIAL_ACCOUNTS_TERRAFORM = <<EOTERRAFORM
{
  "resource": [
    {
      "aws_organizations_account": {
        "wombles-of-wimbledon-common-prod": {
          "name": "wombles-of-wimbledon-common-prod",
          "email": "aws-root-accounts+wom-of-wim-pro@digital.cabinet-office.gov.uk",
          "role_name": "bootstrap",
          "iam_user_access_to_billing": "ALLOW",
          "lifecycle": {"ignore_changes": ["tags"]}
        }
      }
    },
    {
      "aws_organizations_account": {
        "wombles-of-wimbledon-common-staging": {
          "name": "wombles-of-wimbledon-common-staging",
          "email": "aws-root-accounts+wom-of-wim-sta@digital.cabinet-office.gov.uk",
          "role_name": "bootstrap",
          "iam_user_access_to_billing": "ALLOW",
          "lifecycle": {"ignore_changes": ["tags"]}
        }
      }
    }
  ]
}
EOTERRAFORM

class TerraformAccountsServiceTest < ActiveSupport::TestCase
  test 'Adds an account' do
    terraform_accounts_service = TerraformAccountsService.new(INITIAL_ACCOUNTS_TERRAFORM)
    tags = {
      'description' => 'Description.',
      'tag-with-ampersand' => 'Foo&Bar',
      'tag-with-commas' => 'Foo,Bar',
      'tag-with-disallowed-chars' => 'QWERTYUIOPLKJHGFDSSAZXCVBNMqwertuioplkjhgfdsazxcvbnm,./;\'\:\[]{}=-_+)(*^%$£@!~`1234567890'
    }
    result = terraform_accounts_service.add_account(
      'gds-wombles-of-wimbledon-test',
      tags
    )

    expected_tags = {
      'description' => 'Description.',
      'tag-with-ampersand' => 'FooANDBar',
      'tag-with-commas' => 'FooBar',
      'tag-with-disallowed-chars' => "QWERTYUIOPLKJHGFDSSAZXCVBNMqwertuioplkjhgfdsazxcvbnm./:=-_+@1234567890"
    }

    assert_match /"gds-wombles-of-wimbledon-test"/, result
    assert_match /"aws-root-accounts\+wom-of-wim-tes@digital\.cabinet-office\.gov\.uk"/, result
    assert_equal result, JSON.pretty_generate(JSON.parse(result)) + "\n"
    result_tags = JSON.parse(result)["resource"][0]["aws_organizations_account"]['gds-wombles-of-wimbledon-test']['tags']
    assert_equal expected_tags, result_tags
  end
end
