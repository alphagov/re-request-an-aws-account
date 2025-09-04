require 'test_helper'

class EmailValidatorTest < ActiveSupport::TestCase
  # Domains allowed for basic sign-in
  BASIC_ALLOWED_DOMAINS = %w[
    digital.cabinet-office.gov.uk
    cabinetoffice.gov.uk
    gpa.gov.uk
    ipa.gov.uk
    softwire.com
    fidusinfosec.com
    cyberis.com
    pentestpartners.com
    ibca.org.uk
    nista.gov.uk
  ].freeze

  # A subset of domains with advanced permissions to manage other users
  ADVANCED_ALLOWED_DOMAINS = %w[
    digital.cabinet-office.gov.uk
    cabinetoffice.gov.uk
    gpa.gov.uk
    ipa.gov.uk
    ibca.org.uk
    nista.gov.uk
  ].freeze

  BASIC_ONLY_DOMAINS = BASIC_ALLOWED_DOMAINS - ADVANCED_ALLOWED_DOMAINS
  DISALLOWED_DOMAIN = 'example.com'.freeze

  test 'email_is_allowed_basic? correctly validates domains for sign-in' do
    BASIC_ALLOWED_DOMAINS.each do |domain|
      email = "fname.lname@#{domain}"
      assert EmailValidator.email_is_allowed_basic?(email), "Expected #{domain} to be allowed for basic sign-in."
    end

    email = "fname.lname@#{DISALLOWED_DOMAIN}"
    assert_not EmailValidator.email_is_allowed_basic?(email), "Expected #{DISALLOWED_DOMAIN} to be denied for basic sign-in."
  end

  test 'email_is_allowed_advanced? correctly validates domains for user management' do
    ADVANCED_ALLOWED_DOMAINS.each do |domain|
      email = "fname.lname@#{domain}"
      assert EmailValidator.email_is_allowed_advanced?(email), "Expected #{domain} to be allowed for user management."
    end

    (BASIC_ONLY_DOMAINS + [DISALLOWED_DOMAIN]).each do |domain|
      email = "fname.lname@#{domain}"
      assert_not EmailValidator.email_is_allowed_advanced?(email), "Expected #{domain} to be denied for user management."
    end
  end

  test 'allowed_emails_regexp matches all valid email patterns and rejects invalid ones' do
    BASIC_ALLOWED_DOMAINS.each do |domain|
      assert_match EmailValidator.allowed_emails_regexp, "fname.lname@#{domain}"
      assert_match EmailValidator.allowed_emails_regexp, "fname.lname123@#{domain}"
    end

    assert_no_match EmailValidator.allowed_emails_regexp, "fname.lname@#{DISALLOWED_DOMAIN}"
  end

  test 'mixed list of valid emails are matched by the allowed emails regexp' do
    emails = [
      'test.user@digital.cabinet-office.gov.uk',
      'test.user@cabinetoffice.gov.uk',
    ].join(",\n")
    assert_match EmailValidator.allowed_emails_regexp, emails
  end

  test "If ENV['RESTRICT_LOGIN_EMAIL_ADDRESSES_TO'] is set then only allow the specified emails to login" do
    allowed_address = 'allowed.person@digital.cabinet-office.gov.uk'
    disallowed_address = 'notallowed.person@digital.cabinet-office.gov.uk'

    assert EmailValidator.email_is_allowed_basic?(allowed_address)
    assert EmailValidator.email_is_allowed_basic?(disallowed_address)
    assert EmailValidator.email_is_allowed_advanced?(allowed_address)
    assert EmailValidator.email_is_allowed_advanced?(disallowed_address)

    ENV['RESTRICT_LOGIN_EMAIL_ADDRESSES_TO'] = " "
    assert EmailValidator.email_is_allowed_basic?(allowed_address)
    assert EmailValidator.email_is_allowed_basic?(disallowed_address)

    ENV['RESTRICT_LOGIN_EMAIL_ADDRESSES_TO'] = allowed_address
    assert EmailValidator.email_is_allowed_basic?(allowed_address)
    assert_not EmailValidator.email_is_allowed_basic?(disallowed_address)
    assert EmailValidator.email_is_allowed_advanced?(allowed_address)
    assert_not EmailValidator.email_is_allowed_advanced?(disallowed_address)

  ensure
    ENV.delete('RESTRICT_LOGIN_EMAIL_ADDRESSES_TO')
  end
end
