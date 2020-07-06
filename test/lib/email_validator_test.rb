require 'test_helper'

class EmailValidatorTest < ActiveSupport::TestCase
  test 'GDS email addresses are allowed to sign in' do
    email = 'fname.lname@digital.cabinet-office.gov.uk'
    assert EmailValidator.email_is_allowed?(email)
  end

  test 'Cabinet Office email addresses are allowed to sign in' do
    email = 'fname.lname@cabinetoffice.gov.uk'
    assert EmailValidator.email_is_allowed?(email)
  end

  test 'Softwire email addresses are not allowed to sign in' do
    email = 'fname.lname@softwire.com'
    assert ! EmailValidator.email_is_allowed?(email)
  end

  test 'Other email addresses are not allowed to sign in' do
    email = 'fname.lname@example.com'
    assert ! EmailValidator.email_is_allowed?(email)
  end

  test 'GDS emails are matched by the allowed emails regexp' do
    email = 'fname.lname@digital.cabinet-office.gov.uk'
    assert_match EmailValidator.allowed_emails_regexp, email
  end

  test 'Cabinet Office emails are matched by the allowed emails regexp' do
    email = 'fname.lname@cabinetoffice.gov.uk'
    assert_match EmailValidator.allowed_emails_regexp, email
  end

  test 'Softwire emails are matched by the allowed emails regexp' do
    email = 'fname.lname@softwire.com'
    assert_match EmailValidator.allowed_emails_regexp, email
  end

  test 'Other email addresses should not match emails regexp' do
    email = 'fname.lname@example.com'
    assert_no_match EmailValidator.allowed_emails_regexp, email
  end
end
