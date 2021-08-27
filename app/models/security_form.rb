class SecurityForm
  include ActiveModel::Model

  attr_reader :security_requested_alert_priority_level,
              :security_critical_resources_description,
              :security_does_account_hold_pii,
              :security_does_account_hold_pci_data

  validates :security_requested_alert_priority_level,
            presence: true,
            inclusion: { in: %w[P1 P2 P3 P4] }

  validates :security_critical_resources_description,
            presence: true,
            length: { maximum: 256 }

  validates :security_does_account_hold_pii,
            :security_does_account_hold_pci_data,
            presence: true,
            inclusion: { in: %w[yes no] }

  validates_format_of :security_requested_alert_priority_level,
                      :security_critical_resources_description,
                      :security_does_account_hold_pii,
                      :security_does_account_hold_pci_data,
                      with: AwsTagValueValidator.allowed_chars_regexp,
                      message: AwsTagValueValidator.allowed_chars_message

  def initialize(hash)
    params = hash.with_indifferent_access
    @security_requested_alert_priority_level = params[:security_requested_alert_priority_level]
    @security_critical_resources_description = params[:security_critical_resources_description]
    @security_does_account_hold_pii = params[:security_does_account_hold_pii]
    @security_does_account_hold_pci_data = params[:security_does_account_hold_pci_data]
  end
end
