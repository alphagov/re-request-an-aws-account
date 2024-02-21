require "active_support/core_ext/integer/time"

Rails.application.configure do
  # In app runner on aws we need to be able to test on host
  # but ruby doesn't like app runner hosts so we have to add it
  # @TODO remove these once we have perm host/domain set up
  config.hosts = [ENV['RAILS_ALLOWED_DOMAINS']] 

  # Code is not reloaded between requests.
  config.cache_classes = true

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true
  config.action_controller.perform_caching = true
  config.log_level = :debug

  # Ensures that a master key has been made available in either ENV["RAILS_MASTER_KEY"]
  # or in config/master.key. This key is used to decrypt credentials (and other encrypted files).
  # config.require_master_key = true

  # Disable serving static files from the `/public` folder by default since
  # Apache or NGINX already handles this.
  config.public_file_server.enabled = ENV["RAILS_SERVE_STATIC_FILES"].present?

  # Compress CSS using a preprocessor.
  # config.assets.css_compressor = :sass

  # Do not fallback to assets pipeline if a precompiled asset is missed.
  config.assets.compile = false

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.asset_host = "http://assets.example.com"

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for Apache
  # config.action_dispatch.x_sendfile_header = "X-Accel-Redirect" # for NGINX

  # Prepend all log lines with the following tags.
  config.log_tags = [ :request_id ]

  # Use a different cache store in production.
  # config.cache_store = :mem_cache_store

  # Use a real queuing backend for Active Job (and separate queues per environment).
  # config.active_job.queue_adapter     = :resque
  # config.active_job.queue_name_prefix = "re_request_an_aws_account_production"

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
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

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new

  # Use a different logger for distributed setups.
  # require "syslog/logger"
  # config.logger = ActiveSupport::TaggedLogging.new(Syslog::Logger.new "app-name")

  if ENV["RAILS_LOG_TO_STDOUT"].present?
    logger           = ActiveSupport::Logger.new(STDOUT)
    logger.formatter = config.log_formatter
    config.logger    = ActiveSupport::TaggedLogging.new(logger)
  end
end
