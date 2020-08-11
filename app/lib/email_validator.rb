module EmailValidator

  # which allowed domains can sign in to the request an account service
  def self.email_is_allowed?(email)
    return true if email.end_with? '@digital.cabinet-office.gov.uk'
    return true if email.end_with? '@cabinetoffice.gov.uk'
    false
  end

  # which domains are allowed to be requested for a gds-users account
  def self.allowed_emails_regexp
    /\A(#{Regexp.union(
      /([a-z.\-\']+@digital\.cabinet-office\.gov\.uk,?\s*)/,
      /([a-z.\-\']+@cabinetoffice\.gov\.uk,?\s*)/,
      /([a-z.\-\']+@softwire\.com,?\s*)/,
    )})+\z/
  end

end
