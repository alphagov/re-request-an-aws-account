class RequestAnAwsAccountForm
  include ActiveModel::Model

  attr_reader :account_name, :programme, :is_production, :admin_users

  def initialize(hash)
    @account_name = hash[:account_name]
    @programme = hash[:programme]
    @is_production = hash[:is_production]
    @admin_users = hash[:admin_users]
  end
end