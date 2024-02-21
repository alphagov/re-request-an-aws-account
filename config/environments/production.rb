Rails.application.configure do
  # In app runner on aws we need to be able to test on host
  # but ruby doesn't like app runner hosts so we have to add it
  # @TODO remove these once we have perm host/domain set up
  config.hosts = [ENV['RAILS_ALLOWED_DOMAINS']] 

  config.cache_classes = true
  config.eager_load = true
  config.action_controller.perform_caching = true
  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?
  config.log_level = :debug
  config.log_tags = [ :request_id ]
  config.i18n.fallbacks = true
  config.active_support.deprecation = :notify
  config.logger = ActiveSupport::Logger.new(STDERR)

  # so we can run production in localhost we check the allowd domain
  if ENV['RAILS_ALLOWED_DOMAINS'] == "localhost:3000"
    config.consider_all_requests_local = true
    config.force_ssl =  false
  else
    config.consider_all_requests_local = false
    config.force_ssl =  true
  end
  
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
