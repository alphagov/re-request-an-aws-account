require 'test_helper'

class OrganisationSummaryControllerTest < ActionDispatch::IntegrationTest
  include WebMock::API
  setup {
    WebMock.enable!
    set_stub_env_vars
    set_session(
      'test@example.com',
      'organisation' => 'some-name',
      'business_unit' => 'some-business-unit',
      'subsection' => 'subsection',
      'cost_centre_code' => 'cost_centre_code',
      'cost_centre' => 'cost_centre'
    )
  }

  test 'should get index' do
    get organisation_summary_url
    assert_response :success
  end

