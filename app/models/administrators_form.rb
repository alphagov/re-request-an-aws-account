class AdministratorsForm
  include ActiveModel::Model

  attr_reader :admin_users
  validates_each :admin_users do |record, attr, value|
    record.errors.add attr, 'is required' if value.nil? || value.empty?
  end

  def initialize(hash)
    @admin_users = hash[:admin_users]
  end
end