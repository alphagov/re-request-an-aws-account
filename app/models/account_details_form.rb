class AccountDetailsForm
  include ActiveModel::Model

  attr_reader :account_name, :is_production
  validates_format_of :account_name, with: /\A([a-z]+-)*[a-z]+\z/, message: 'should be kebab-cased'
  validates_each :account_name, :is_production do |record, attr, value|
    record.errors.add attr, 'is required' if value.nil? || value == ''
  end


  def initialize(hash)
    params = hash.with_indifferent_access
    @account_name = params[:account_name]
    @is_production = params[:is_production] == 'true'
  end
end