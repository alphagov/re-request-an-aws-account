require 'test_helper'

class CheckYourAnswersControllerTest < ActionDispatch::IntegrationTest
  setup { set_session 'test@example.com', 'account_name' => 'some-name', 'programme' => 'GOV.UK' }

  test 'should get index' do
    get check_your_answers_url
    assert_response :success
  end

  test 'should redirect on valid session' do
    post check_your_answers_url
    assert_redirected_to confirmation_account_url
  end

end
