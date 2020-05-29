require 'test_helper'

class AdministratorsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in 'test@example.com' }

  test 'should get index' do
    get administrators_url
    assert_response :success
  end

  test 'should validate form' do
    post administrators_url, params: { administrators_form: { } }
    assert_response :success
    assert_select '.error-message', 'Admin users should be a list of GDS emails'
  end

  [
    %w[GDS digital.cabinet-office.gov.uk],
    %w[CabinetOffice cabinetoffice.gov.uk],
  ].each do |org, email_suffix|
    test "should redirect on valid form containing #{org} users" do
      post administrators_url, params: { administrators_form: { admin_users: "test.user@#{email_suffix}" } }
      assert_redirected_to check_your_answers_url
    end
  end
end
