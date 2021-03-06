# frozen_string_literal: true

require 'bundler/setup'
require 'webmock/rspec'
require 'panda_bot'
require 'byebug'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |conf|
    conf.syntax = :expect
  end
end
