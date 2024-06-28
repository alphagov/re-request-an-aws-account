
class OrganisationForm
  include ActiveModel::Model

  attr_reader :organisation, :cost_centre_code, :cost_centre_description, :business_unit, :subsection
  validate :organisation_specified, :cost_centre_code_specified

  validates_format_of :organisation,
                      :cost_centre_code,
                      with: AwsTagValueValidator.allowed_chars_regexp,
                      message: AwsTagValueValidator.allowed_chars_message

  def initialize(hash, cost_centres, logger)
    params = hash.with_indifferent_access
    @organisation = params[:organisation]
    @cost_centre_code = params[:cost_centre_code]

    if cost_centres.nil?     
      return
    end

    @cost_centre_data = cost_centres.get_by_cost_centre_code(@cost_centre_code)
  end

  def organisation_specified
    errors.add(:organisation_specified, 'Billing information is required') if organisation.to_s.empty?
  end

  def cost_centre_code_specified
    if organisation.to_s != "Cabinet Office"
      return
    end

    if cost_centre_code.to_s.empty?
      errors.add(:cost_centre_code_specified, 'Enter a cost centre')
      return
    end

    if @cost_centre_data.nil?
      errors.add(:cost_centre_code_specified, 'Cost centre code not found')
      return
    end
    
    @cost_centre_description = @cost_centre_data.cost_centre_description
    @business_unit = @cost_centre_data.business_unit
    @subsection = @cost_centre_data.subsection
  end

end
