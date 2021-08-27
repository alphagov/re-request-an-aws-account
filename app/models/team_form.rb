class TeamForm
  include ActiveModel::Model

  attr_reader :team_name, :team_email_address, :team_lead_name,
              :team_lead_email_address, :team_lead_phone_number,
              :team_lead_role

  validates :team_name, :team_email_address, :team_lead_name,
            :team_lead_role, presence: true, length: { maximum: 256 }

  validate :at_least_one_contact_detail_provided?

  validates_format_of :team_name,
                      :team_email_address,
                      :team_lead_name,
                      :team_lead_email_address,
                      :team_lead_phone_number,
                      :team_lead_role,
                      with: AwsTagValueValidator.allowed_chars_regexp,
                      message: AwsTagValueValidator.allowed_chars_message

  def at_least_one_contact_detail_provided?
    contact_fields = %w(
      team_lead_email_address
      team_lead_phone_number
    )

    if contact_fields.all? { |attr| send(attr).blank? }
      errors.add :base, "A team lead email address or phone number must be provided"
    end
  end

  def initialize(hash)
    params = hash.with_indifferent_access
    @team_name = params[:team_name]
    @team_email_address = params[:team_email_address]
    @team_lead_name = params[:team_lead_name]
    @team_lead_email_address = params[:team_lead_email_address]
    @team_lead_phone_number = params[:team_lead_phone_number]
    @team_lead_role = params[:team_lead_role]
  end
end
