class UserForm
  include ActiveModel::Model

  attr_reader :email_list
  validates_format_of :email_list,
                      with: /\A([a-z.\-]+@digital.cabinet-office.gov.uk,?\s*)+\z/,
                      message: 'should be a list of GDS emails'
  validates_each :email_list do |record, attr, value|
    record.errors.add attr, 'is required' if value.nil? || value == ''
  end


  def initialize(hash)
    params = hash.with_indifferent_access
    @email_list = params[:email_list]
  end
end