# frozen_string_literal: true

module Fnsapi
  class InvalidConfigurationError < StandardError; end

  class Configuration
    attr_accessor :fns_host,
                  :fns_port,
                  :redis_key,
                  :redis_url,
                  :tmp_file_name,
                  :get_message_timeout,
                  :log_enabled,
                  :logger

    attr_writer :fnsapi_user_token,
                :fnsapi_master_key

    def initialize
      @fns_host = 'https://openapi.nalog.ru'
      @fns_port = 8090
      @redis_key = :fnsapi_token
      @redis_url = nil
      @tmp_file_name = 'fnsapi_tmp_credentials'
      @fnsapi_master_key = nil
      @fnsapi_user_token = nil
      @get_message_timeout = 60
      @logger = defined?(Rails) ? Rails.logger : Logger.new($stdout)
      @log_enabled = false
    end

    def fnsapi_user_token
      return @fnsapi_user_token if @fnsapi_user_token

      raise InvalidConfigurationError, 'fnsapi_user_token must be specified'
    end

    def fnsapi_master_key
      return @fnsapi_master_key if @fnsapi_master_key

      raise InvalidConfigurationError, 'fnsapi_master_key must be specified'
    end
  end
end
