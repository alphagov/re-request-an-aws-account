class AccountDetailsForm
  include ActiveModel::Model

  attr_reader :account_name, :account_description
  validates_format_of :account_name, with: /\A([a-z]+-)*[a-z]+\z/, message: 'should be lower-case-separated-by-dashes'
  validates_each :account_name, :account_description do |record, attr, value|
    record.errors.add attr, 'is required' if value.nil? || value == ''
  end


  def initialize(hash)
    params = hash.with_indifferent_access
    @account_name = params[:account_name]
    @account_description = params[:account_description]
  end
end