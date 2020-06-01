require 'test_helper'
require 'webmock'

USER_MANAGEMENT_GITHUB_API = "https://api.github.com/repos/alphagov/aws-user-management-account-users"

class UserControllerTest < ActionDispatch::IntegrationTest
  include WebMock::API

  setup {
    WebMock.enable!
    set_stub_env_vars
    sign_in 'test@example.com'
  }

  teardown {
    WebMock.reset!
    WebMock.disable!
    reset_env_vars
  }

  test 'should get index' do
    get user_url
    assert_response :success
  end

  test 'should validate form' do
    post user_url, params: { user_form: { email_list: 'test.user@example.com' } }
    assert_response :success
    assert_select '.error-message', 'GDS email addresses should be a list of GDS emails'
  end

  [
    %w[GDS digital.cabinet-office.gov.uk],
    %w[CabinetOffice cabinetoffice.gov.uk],
  ].each do |org, email_suffix|
    test "should create pull request to add user from #{org}, email the users and redirect with pull_request_url in session" do
      stub_notify_emails
      users_terraform_before = build_content_request(resource:[])
      cross_account_terraform_before = build_content_request(
        resource: { aws_iam_group_membership: { "crossaccountaccess-members" => { users: [] } } }
      )
      stub_create_user_github_api(
        users_terraform_before,
        cross_account_terraform_before,
        "https://some-add-user-pull-request-url",
      )

      post(user_url, params: { user_form: { email_list: "test.user@#{email_suffix}" } })

      users_terraform_after = assert_content_updated(USER_MANAGEMENT_GITHUB_API, "/terraform/gds_users.tf")
      assert_equal(
        [ {"aws_iam_user"=>{"test_user"=>{"name"=>"test.user@#{email_suffix}", "force_destroy"=>true}}}],
        users_terraform_after.dig('resource'))

      cross_account_terraform_after = assert_content_updated(USER_MANAGEMENT_GITHUB_API, "/terraform/iam_crossaccountaccess_members.tf")
      assert_equal(
        ["${aws_iam_user.test_user.name}"],
        cross_account_terraform_after.dig('resource', 'aws_iam_group_membership', 'crossaccountaccess-members', 'users')
      )

      emails = assert_notify_emails_sent
      assert_equal 2, emails.length
      assert_equal(
        %w(gds-aws-account-management@digital.cabinet-office.gov.uk test@example.com).to_set,
        emails.map{|e|e['email_address']}.to_set
      )

      assert_redirected_to confirmation_user_url
      assert_equal "https://some-add-user-pull-request-url", read_from_session("pull_request_url")
    end
  end

private

  def stub_create_user_github_api(users_terraform, cross_account_terraform, resulting_pull_request_url)
    stub_request(:get, "#{USER_MANAGEMENT_GITHUB_API}/contents/terraform/gds_users.tf").
      to_return(status: 200, body: users_terraform, headers: {'Content-Type' => 'application/json'})

    stub_request(:get, "#{USER_MANAGEMENT_GITHUB_API}/contents/terraform/iam_crossaccountaccess_members.tf").
      to_return(status: 200, body: cross_account_terraform, headers: {'Content-Type' => 'application/json'})

    stub_request(:get, "#{USER_MANAGEMENT_GITHUB_API}/commits/master").
      to_return(status: 200, body: '{"sha":"somesha"}', headers: {'Content-Type' => 'application/json'})

    stub_request(:post, "#{USER_MANAGEMENT_GITHUB_API}/git/refs").
      to_return(status: 200, body: '{}', headers: {'Content-Type' => 'application/json'})

    stub_request(:put, "#{USER_MANAGEMENT_GITHUB_API}/contents/terraform/gds_users.tf").
      to_return(status: 200, body: '{}', headers: {'Content-Type' => 'application/json'})

    stub_request(:put, "#{USER_MANAGEMENT_GITHUB_API}/contents/terraform/iam_crossaccountaccess_members.tf").
      to_return(status: 200, body: '{}', headers: {'Content-Type' => 'application/json'})

    stub_request(:post, "#{USER_MANAGEMENT_GITHUB_API}/pulls").
      to_return(status: 200, body: '{"html_url": "' + resulting_pull_request_url + '"}', headers: {'Content-Type' => 'application/json'})
  end
end
