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

  def assert_content_updated(repository_api, path)
    body = nil
    assert_requested(:put, "#{repository_api}/contents#{path}") do |req|
      body = req.body
      true
    end
    assert_not_nil body
    body_json = assert_nothing_raised { JSON.parse(body) }
    assert_not_nil body_json["content"]
    content_decoded = assert_nothing_raised { Base64.decode64(body_json["content"]) }
    return assert_nothing_raised { JSON.parse(content_decoded) }
  end

  def build_content_request(input)
    JSON.dump(content: Base64.encode64(JSON.dump(input)))
  end
end
