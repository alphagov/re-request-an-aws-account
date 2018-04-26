class AdministratorsForm
  include ActiveModel::Model

  attr_reader :admin_users

  def initialize(hash)
    @admin_users = hash[:admin_users]
  end
end