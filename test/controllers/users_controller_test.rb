require 'test_helper'

class UserControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in 'test@example.com' }

  test 'should get index' do
    get user_url
    assert_response :success
  end

  test 'should validate form' do
    post user_url, params: { user_form: { email_list: 'test.user@example.com' } }
    assert_response :success
    assert_select '.error-message', 'GDS email addresses should be a list of GDS emails'
  end

  test 'should redirect on valid form' do
    post user_url, params: { user_form: { email_list: 'test.user@digital.cabinet-office.gov.uk' } }
    assert_redirected_to confirmation_user_url
  end
end
