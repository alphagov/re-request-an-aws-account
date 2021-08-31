class OutOfHoursSupportForm
  include ActiveModel::Model

  attr_reader :out_of_hours_support_contact_name,
              :out_of_hours_support_phone_number,
              :out_of_hours_support_pagerduty_link,
              :out_of_hours_support_email_address

  validates :out_of_hours_support_phone_number,
            presence: true,
            length: { maximum: 256 }

  validates :out_of_hours_support_contact_name,
            :out_of_hours_support_pagerduty_link,
            :out_of_hours_support_email_address,
            length: { maximum: 256 }

  validates_format_of :out_of_hours_support_contact_name,
                      :out_of_hours_support_phone_number,
                      :out_of_hours_support_pagerduty_link,
                      :out_of_hours_support_email_address,
                      with: AwsTagValueValidator.allowed_chars_regexp,
                      message: AwsTagValueValidator.allowed_chars_message

  def initialize(hash)
    params = hash.with_indifferent_access
    @out_of_hours_support_contact_name = params[:out_of_hours_support_contact_name]
    @out_of_hours_support_phone_number = params[:out_of_hours_support_phone_number]
    @out_of_hours_support_pagerduty_link = params[:out_of_hours_support_pagerduty_link]
    @out_of_hours_support_email_address = params[:out_of_hours_support_email_address]
  end
end
