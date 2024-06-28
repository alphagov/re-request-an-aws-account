require 'test_helper'

class OrganisationControllerTest < ActionDispatch::IntegrationTest
  setup {
    sign_in 'test@example.com'
    set_session(
      'test@example.com',
      'organisation' => 'Government Digital Service',
    )
  }

  test 'should get index' do
    get organisation_url
    assert_response :success
  end

  test 'should validate empty form' do
    post organisation_url, params: { organisation_form: { organisation: nil } }
    assert_response :success
    assert_select '.govuk-error-message', 'Billing information is required'
  end


  test 'should error if cost centre code is not entered when Cabinet Office selected' do
    post organisation_url, params: { organisation_form: { organisation: "Cabinet Office"} }
    assert_select '.govuk-error-message', 'Enter a cost centre'
  end

  test 'should error if cost centre code is not found in reader' do
    post organisation_url, params: { organisation_form: { organisation: "Cabinet Office", cost_centre_code: "99999"} }
    assert_select '.govuk-error-message', 'Cost centre code not found'
  end

  test 'should save cost centre data to session'  do
    post organisation_url, params: { organisation_form: { organisation: "Cabinet Office", cost_centre_code: "12345678"} }
    
    session_form = session[:form]
    puts session_form
    assert_equal session_form[:organisation], "Cabinet Office"
    assert_equal session_form[:cost_centre_code], "12345678"
    assert_equal session_form[:cost_centre_description], "BOOM"
    assert_equal session_form[:business_unit], "BING"
    assert_equal session_form[:subsection], "BAZ"


  end 
end