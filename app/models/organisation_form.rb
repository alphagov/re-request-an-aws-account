class OrganisationForm
  include ActiveModel::Model

  attr_reader :organisation, :organisation_other
  validate :organisation_or_other_specified, :organisation_and_other_not_both_specified

  validates_format_of :organisation,
                      :organisation_other,
                      with: AwsTagValueValidator.allowed_chars_regexp,
                      message: AwsTagValueValidator.allowed_chars_message

  def initialize(hash)
    params = hash.with_indifferent_access
    @organisation = params[:organisation]
    @organisation_other = params[:organisation_other]
  end

  def organisation_or_other
    is_other ? organisation_other : organisation
  end

  def is_other
    organisation.to_s.empty? || organisation == 'Other'
  end

  def organisation_or_other_specified
    errors.add(:organisation_or_other_specified, 'Organisation is required') if organisation_or_other.to_s.empty?
  end

  def organisation_and_other_not_both_specified
    if !organisation.to_s.empty? && organisation != 'Other' && !organisation_other.to_s.empty?
      errors.add(:organisation_or_other_specified, 'Only one of Organisation and Other should be set')
    end
  end

end
