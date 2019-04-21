# frozen_string_literal: true

require 'fnsapi/version'
require 'fnsapi/configuration'
require 'fnsapi/tmp_storage'
require 'fnsapi/base_service'
require 'fnsapi/auth_service'
require 'fnsapi/kkt_concern'
require 'fnsapi/get_message_service'
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
