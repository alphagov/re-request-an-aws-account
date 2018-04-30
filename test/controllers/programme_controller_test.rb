require 'test_helper'

class ProgrammeControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in 'test@example.com' }

  test 'should get index' do
    get programme_url
    assert_response :success
  end

  test 'should validate form' do
    post programme_url, params: { programme_form: { programme: nil } }
    assert_response :success
    assert_select '.error-message', 'Field is required'
  end

  test 'should redirect on valid form' do
    post programme_url, params: { programme_form: { programme: 'GOV.UK' } }
    assert_redirected_to administrators_url
  end
end
