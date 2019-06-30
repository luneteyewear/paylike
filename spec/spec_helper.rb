require 'bundler/setup'
require 'simplecov'
require 'vcr'

SimpleCov.start do
  add_group 'Lib', 'lib'
  add_group 'Tests', 'spec'
end
SimpleCov.minimum_coverage 90

VCR.configure do |config|
  config.cassette_library_dir = 'vcr_cassettes'
  config.hook_into :webmock

  %w[PAYLIKE_KEY PAYLIKE_MERCHANT_ID PAYLIKE_PUBLIC_KEY].each do |pkey|
    ENV[pkey] ||= 'secret'
    config.filter_sensitive_data("<#{pkey}>") { ENV[pkey] }
  end

  config.filter_sensitive_data('<AUTH_TOKEN>') do |interaction|
    auth_headers = interaction.request.headers['Authorization'] || []
    auth_headers.first.to_s.split(' ').last
  end
end

require 'paylike'
require 'ffaker'

RSpec.configure do |config|
  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
