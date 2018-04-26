class AccountDetailsForm
  include ActiveModel::Model

  attr_reader :account_name, :is_production
  validates_each :account_name, :is_production do |record, attr, value|
    record.errors.add attr, 'is required' if value.nil? || value.empty?
  end


  def initialize(hash)
    @account_name = hash[:account_name]
    @is_production = hash[:is_production]
  end
end