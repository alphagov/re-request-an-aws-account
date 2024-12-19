require 'ostruct'
require 'capybara'
require 'capybara/rspec'
require 'capybara/mechanize'

Capybara.register_driver :mechanize_driver do |app|
 Capybara::Mechanize::Driver.new(proc {})
end

Capybara.default_driver = :mechanize_driver
Capybara.app_host = ENV.fetch('SMOKE_TEST_HOST', 'https://request-an-aws-account-test.gds-reliability.engineering/')
Capybara.run_server = false

RSpec.configure do |config|
 config.include Capybara::DSL
  config.expect_with :rspec do |expectations|
   expectations.include_chain_clauses_in_custom_matcher_descriptions = true
 end

 config.mock_with :rspec do |mocks|
   mocks.verify_partial_doubles = true
 end

 config.shared_context_metadata_behavior = :apply_to_host_groups
end
