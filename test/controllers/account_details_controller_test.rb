require 'test_helper'

class AccountDetailsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in 'test@example.com' }

  test 'should get index' do
    get account_details_url
    assert_response :success
  end

  test 'should validate form' do
    post account_details_url, params: { account_details_form: { account_name: 'BAD ACCOUNT NAME' } }
    assert_response :success
    assert_select '.error-message', 'Account name should be kebab-cased'
  end

  test 'should redirect on valid form' do
    post account_details_url, params: { account_details_form: { account_name: 'good-account-name', is_production: false } }
    assert_redirected_to programme_url
  end
end
