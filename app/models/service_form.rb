class ServiceForm
  include ActiveModel::Model

  attr_reader :service_name, :service_is_out_of_hours_support_provided

  validates :service_name,
            presence: true,
            length: { maximum: 256 }

  validates :service_is_out_of_hours_support_provided,
            presence: true,
            inclusion: { in: %w[true false] }

  validates_format_of :service_name,
                      with: AwsTagValueValidator.allowed_chars_regexp,
                      message: AwsTagValueValidator.allowed_chars_message

  def initialize(hash)
    params = hash.with_indifferent_access
    @service_name = params[:service_name]
    @service_is_out_of_hours_support_provided = params[:service_is_out_of_hours_support_provided]
  end
end
