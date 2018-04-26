class AccountDetailsForm
  include ActiveModel::Model

  attr_reader :account_name, :is_production

  def initialize(hash)
    @account_name = hash[:account_name]
    @is_production = hash[:is_production]
  end
end