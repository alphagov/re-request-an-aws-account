module EmailValidator
  def self.email_is_allowed?(email)
    return true if email.end_with? '@digital.cabinet-office.gov.uk'
    return true if email.end_with? '@cabinetoffice.gov.uk'
    false
  end

  def self.allowed_emails_regexp
    Regexp.union(
      /\A([a-z.\-]+@digital.cabinet-office.gov.uk,?\s*)+\z/,
      /\A([a-z.\-]+@cabinetoffice.gov.uk,?\s*)+\z/,
    )
  end

end
