ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'

class ActiveSupport::TestCase
  def sign_in(email)
    put ::RackSessionAccess.path, params: { data: ::RackSessionAccess.encode({ 'email' => email }) }
    follow_redirect!
  end

  def set_session(email, form)
    put ::RackSessionAccess.path, params: { data: ::RackSessionAccess.encode({ 'email' => email, 'form' => form }) }
    follow_redirect!
  end
end
