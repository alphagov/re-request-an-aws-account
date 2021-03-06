require 'test_helper'
require 'webmock'

ACCOUNT_MANAGEMENT_GITHUB_API = "https://api.github.com/repos/alphagov/aws-billing-account"

class CheckYourAnswersControllerTest < ActionDispatch::IntegrationTest
  include WebMock::API
  setup {
    WebMock.enable!
    set_stub_env_vars
    set_session(
      'test@example.com',
      'account_name' => 'some-name',
      'programme' => 'GOV.UK',
      'account_description' => 'some account description',
    )
  }

  teardown {
    WebMock.reset!
    WebMock.disable!
    reset_env_vars
  }

  test 'should get index' do
    get check_your_answers_url
    assert_response :success
  end

  test 'should raise a PR for a new account, email the users and redirect with the PR url in session' do
    accounts_terraform_before = build_content_request({ resource: [] })
    stub_notify_emails
    stub_create_account_github_api(
      accounts_terraform_before,
      "https://some-new-account-pull-request-url")
    post check_your_answers_url

    accounts_terraform_after = assert_content_updated(ACCOUNT_MANAGEMENT_GITHUB_API, '/terraform/accounts.tf')
    assert_equal(
      {
        "some-name" => {
          "name" => "some-name",
          "email" => "aws-root-accounts+some-name@digital.cabinet-office.gov.uk",
          "role_name" => "bootstrap",
          "iam_user_access_to_billing" => "ALLOW",
          "lifecycle" => { "ignore_changes" => ["tags"]}
        }
      },
      accounts_terraform_after['resource'][0]['aws_organizations_account']
    )

    emails = assert_notify_emails_sent
    assert_equal(2, emails.length)
    assert_equal(
      %w(gds-aws-account-management@digital.cabinet-office.gov.uk test@example.com).to_set,
      emails.map{|e|e['email_address']}.to_set
    )

    assert_redirected_to confirmation_account_url
    assert_equal "https://some-new-account-pull-request-url", read_from_session("pull_request_url")
  end

  test 'should handle the case where there is missing session data' do
    accounts_terraform_before = build_content_request({ resource: [] })
    stub_create_account_github_api(
      accounts_terraform_before,
      "https://some-new-account-pull-request-url")

    set_session(
      'test@example.com',
      'account_name' => 'some-name'
    )

    post check_your_answers_url

    assert_response 200
  end

  def stub_create_account_github_api(accounts_terraform, resulting_pull_request_url)
    stub_request(:get, "#{ACCOUNT_MANAGEMENT_GITHUB_API}/commits/master").
      to_return(status: 200, body: '{"sha":"somesha"}', headers: {'Content-Type' => 'application/json'})

    stub_request(:post, "#{ACCOUNT_MANAGEMENT_GITHUB_API}/git/refs").
      to_return(status: 200, body: '{}', headers: {'Content-Type' => 'application/json'})

    stub_request(:get, "#{ACCOUNT_MANAGEMENT_GITHUB_API}/contents/terraform/accounts.tf").
     to_return(status: 200, body: accounts_terraform, headers: {'Content-Type' => 'application/json'})

    stub_request(:put, "#{ACCOUNT_MANAGEMENT_GITHUB_API}/contents/terraform/accounts.tf").
      to_return(status: 200, body: '{}', headers: {'Content-Type' => 'application/json'})

    stub_request(:post, "#{ACCOUNT_MANAGEMENT_GITHUB_API}/pulls").
      to_return(status: 200, body: '{"html_url": "' + resulting_pull_request_url + '"}', headers: {'Content-Type' => 'application/json'})
  end
end
