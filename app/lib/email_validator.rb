module EmailValidator

  # which allowed domains can sign in to the request an account service
  def self.email_is_allowed_basic?(email)
    return true if email.end_with? '@digital.cabinet-office.gov.uk'
    return true if email.end_with? '@cabinetoffice.gov.uk'
    return true if email.end_with? '@softwire.com'
    return true if email.end_with? '@fidusinfosec.com'
    false
  end

  # which allowed domains can request accounts, new users, remove users, etc.
  def self.email_is_allowed_advanced?(email)
    return true if email.end_with? '@digital.cabinet-office.gov.uk'
    return true if email.end_with? '@cabinetoffice.gov.uk'
    false
  end

  # which domains are allowed to be requested for a gds-users account
  def self.allowed_emails_regexp
    /\A(#{Regexp.union(
      /([a-zA-Z.\-\']+@digital\.cabinet-office\.gov\.uk,?\s*)/,
      /([a-zA-Z.\-\']+@cabinetoffice\.gov\.uk,?\s*)/,
      /([a-zA-Z.\-\']+@softwire\.com,?\s*)/,
      /([a-zA-Z.\-\']+@fidusinfosec\.com,?\s*)/,
    )})+\z/
  end

end
