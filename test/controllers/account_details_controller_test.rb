require 'test_helper'

class AccountDetailsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in 'test@example.com' }

  test 'should get index' do
    get account_details_url
    assert_response :success
  end

  test 'should validate form' do
    post account_details_url, params: { account_details_form: { account_name: 'BAD ACCOUNT NAME', account_description: 'some description' } }
    assert_response :success
    assert_select '.govuk-error-message', 'Error:Account name should be lower-case-separated-by-dashes'
  end

  test 'should redirect on valid form' do
    post account_details_url, params: { account_details_form: { account_name: 'good-account-name', account_description: 'some description' } }
    assert_redirected_to organisation_url
  end
end
