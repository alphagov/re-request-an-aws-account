Rails.application.configure do
  config.logger = ActiveSupport::Logger.new(STDERR)
  config.lograge.enabled = true
  config.lograge.formatter = Lograge::Formatters::Logstash.new
end
