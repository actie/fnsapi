# frozen_string_literal: true

require 'bundler/setup'
require 'fnsapi'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

class StubbedFile
  def truncate(_); end
  def write(_); end
  def rewind; end
  def read; end
end

class StubbedTmpStorage
  def initialize; end
  def write_token(_, _); end
  def token; end
end

class Redis
  def initialize(_); end
  def set(_, _); end
  def expireat(_, _); end
end
