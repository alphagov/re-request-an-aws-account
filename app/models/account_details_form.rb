class AccountDetailsForm
  include ActiveModel::Model

  attr_reader :account_name, :account_description

  validates_format_of :account_name, with: /\A([a-z]+-)*[a-z]+\z/, message: 'should be lower-case-separated-by-dashes'
  validates_format_of :account_name, with: /\A([a-z]+-){0,4}[a-z]+\z/, message: 'should not have more-than-five-groups-separated-by-dashes'

  validates :account_name, :account_description, presence: true, length: { maximum: 256 }

  validates_format_of :account_description, with: /\A[\w .:\/=+-@]+\z/, message: 'should only consist of alphanumeric characters, spaces and the characters .:/=+-@'

  def initialize(hash)
    params = hash.with_indifferent_access
    @account_name = params[:account_name]
    @account_description = params[:account_description]
  end
end
