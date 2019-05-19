ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'

class ActiveSupport::TestCase

  def set_stub_env_vars
    ENV['GITHUB_PERSONAL_ACCESS_TOKEN'] = 'SOME_VALUE'
  end

  def reset_env_vars
    ENV.delete('GITHUB_PERSONAL_ACCESS_TOKEN')
  end

  def sign_in(email)
    put ::RackSessionAccess.path, params: { data: ::RackSessionAccess.encode({ 'email' => email }) }
    follow_redirect!
  end

  def set_session(email, form)
    put ::RackSessionAccess.path, params: { data: ::RackSessionAccess.encode({ 'email' => email, 'form' => form }) }
    follow_redirect!
  end

  def read_from_session(key)
    get "#{::RackSessionAccess.path}.raw"
    session = RackSessionAccess.decode(html_document.css("pre").inner_html)
    session[key]
  end
end
