# frozen_string_literal: true

require 'savon'

module Fnsapi
  class RequestError < StandardError; end
  class NotImplementedError < StandardError; end

  class BaseService
    def client(additional_params = {})
      Savon.client(client_params(additional_params))
    end

    private

    def namespaces
      { 'xmlns:xs' => 'http://www.w3.org/2001/XMLSchema' }
    end

    def client_params(additional_params = {})
      {
        wsdl: "#{fns_url}#{uri}",
        namespaces: namespaces,
        env_namespace: :soap,
        log: Fnsapi.configuration.log_enabled,
        logger: Fnsapi.configuration.logger,
        proxy: Fnsapi.configuration.proxy_url
      }.merge(additional_params)
    end

    def uri
      raise NotImplementedError
    end

    def redis
      return false unless Fnsapi.configuration.redis_url

      @redis ||= Redis.new(url: Fnsapi.configuration.redis_url)
    end

    def tmp_storage
      @tmp_storage ||= TmpStorage.new
    end

    def token
      if redis
        redis.get(Fnsapi.configuration.redis_key)
      else
        tmp_storage.token
      end
    end

    def fns_url
      "#{Fnsapi.configuration.fns_host}:#{Fnsapi.configuration.fns_port}"
    end
  end
end
