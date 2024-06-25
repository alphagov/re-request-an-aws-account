
class OrganisationForm
  include ActiveModel::Model

  attr_reader :organisation, :cost_centre_code
  validate :organisation_specified, :cost_centre_code_specified

  validates_format_of :organisation,
                      :cost_centre_code,
                      with: AwsTagValueValidator.allowed_chars_regexp,
                      message: AwsTagValueValidator.allowed_chars_message

  def initialize(hash, cost_centres)
    params = hash.with_indifferent_access
    @organisation = params[:organisation]
    @cost_centre_code = params[:cost_centre_code]
    @cost_centres = cost_centres
  end

  def organisation_specified
    errors.add(:organisation_specified, 'Billing information is required') if organisation.to_s.empty?
  end

  def cost_centre_code_specified
    if organisation.to_s == "Cabinet Office" 
      if cost_centre_code.to_s.empty?
        errors.add(:cost_centre_code_specified, 'Enter a cost centre')
      elsif @cost_centres.get_by_cost_centre_code(:cost_centre_code).nil?
        errors.add(:cost_centre_code_specified, 'Cost centre code not found')
      end
    end
  end

end
