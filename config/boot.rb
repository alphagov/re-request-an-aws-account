ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

require 'bundler/setup'

require 'rails/command'
require 'rails/commands/server/server_command'

module Rails
  class Server < ::Rack::Server
    alias_method :orig_initialize, :initialize
    def initialize(options)
      orig_initialize(options.merge(AccessLog: []))
    end
  end
end
