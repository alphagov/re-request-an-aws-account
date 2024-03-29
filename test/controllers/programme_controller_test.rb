require 'test_helper'

class ProgrammeControllerTest < ActionDispatch::IntegrationTest
  setup {
    sign_in 'test@example.com'
    set_session(
      'test@example.com',
      'organisation' => 'Government Digital Service',
    )
  }

  test 'should get index' do
    get programme_url
    assert_response :success
  end

  test 'should validate empty form' do
    post programme_url, params: { programme_form: { programme: nil } }
    assert_response :success
    assert_select '.govuk-error-message', 'Error:Programme is required'
  end

  test 'should validate form with programme and other set' do
    post programme_url, params: { programme_form: { programme: 'GOV.UK', programme_other: 'Brexit' } }
    assert_response :success
    assert_select '.govuk-error-message', 'Error:Only one of Programme and Other should be set'
  end

  test 'should validate allowed characters of programme other' do
    post programme_url, params: { programme_form: { programme: 'Other', programme_other: 'Quiche (vegan!)' } }
    assert_response :success
    assert_select '.govuk-error-message', 'Error:Programme other should only consist of alphanumeric characters, spaces and the characters .:/=+-@'
  end

  test 'should redirect on valid form with programme' do
    post programme_url, params: { programme_form: { programme: 'GOV.UK' } }
    assert_redirected_to team_url
  end

  test 'should redirect on valid form with other programme' do
    post programme_url, params: { programme_form: { programme: 'Other', programme_other: 'Brexit' } }
    assert_redirected_to team_url
  end

  test 'should redirect on valid form with nil programme but other set' do
    post programme_url, params: { programme_form: { programme: nil, programme_other: 'Brexit' } }
    assert_redirected_to team_url
  end
end
