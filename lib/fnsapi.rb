# frozen_string_literal: true

require 'fnsapi/version'
require 'fnsapi/configuration'
require 'fnsapi/auth_service'
require 'fnsapi/kkt_service'

module Fnsapi
  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end
  end
end
