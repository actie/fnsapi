# frozen_string_literal: true

require 'tmp_credentials'

module FnsApi
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
        env_namespace: :soap
      }.merge(additional_params)
    end

    def uri
      raise NotImplementedError
    end

    def redis
      return false unless configuration.redis_url

      @redis ||= Redis.new(url: configuration.redis_url)
    end

    def tmp_credentials
      @tmp_credentials ||= TmpCredentials.new
    end

    def token
      if redis
        redis.get(configuration.redis_key)
      else
        tmp_credentials.token
      end
    end

    def fns_url
      "#{configuration.fns_host}:#{configuration.fns_port}"
    end
  end
end
