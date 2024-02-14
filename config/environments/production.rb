Rails.application.configure do
  # In app runner on aws we need to be able to test on host
  # but ruby doesn't like app runner hosts so we have to add it
  # @TODO remove these once we have perm host/domain set up
  config.hosts << "dz83ne5st5.eu-west-2.awsapprunner.com"

  
  config.cache_classes = true
  config.eager_load = true
  config.action_controller.perform_caching = true
  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?
  config.log_level = :debug
  config.log_tags = [ :request_id ]
  config.i18n.fallbacks = true
  config.active_support.deprecation = :notify
  config.logger = ActiveSupport::Logger.new(STDERR)

  # so we can run production config in localhost to check it
  # remove the force ssl config if env var set to false
  # and ensure default will always be true
  ENV['RAILS_FORCE_SSL'].blank? ? config.force.ssl = true :  config.force_ssl = ENV['RAILS_FORCE_SSL'].present?

  # so we can run procudion config in localhost to check it
  # if env var is set to true consider all request to be local and allow hosts
  config.consider_all_requests_local = ENV['RAILS_ALLOW_LOCALHOST'].present?
  config.hosts << "localhost:3000" if ENV['RAILS_ALLOW_LOCALHOST'].present?
  
  # Define a content security policy
  # For further information see the following documentation
  # https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy

  config.content_security_policy do |policy|
    policy.default_src :self
    policy.font_src    :self
    policy.img_src     :self
    policy.object_src  :none
    policy.script_src  :self
    policy.style_src   :self

    # Specify URI for violation reports
    # policy.report_uri "/csp-violation-report-endpoint"
  end
  config.content_security_policy_nonce_generator = -> request { SecureRandom.base64(16) }

end
