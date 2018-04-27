class UserForm
  include ActiveModel::Model

  attr_reader :email
  validates_format_of :email, with: /\A[a-z.\-]+@digital.cabinet-office.gov.uk,?\s*\z/, message: 'should be a GDS email'
  validates_each :email do |record, attr, value|
    record.errors.add attr, 'is required' if value.nil? || value == ''
  end


  def initialize(hash)
    params = hash.with_indifferent_access
    @email = params[:email]
  end
end