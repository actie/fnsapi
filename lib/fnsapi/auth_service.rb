# frozen_string_literal: true

require 'base_service'

module FnsApi
  class AuthService < BaseService
    def reset_credentials
      result = client.call(:get_message, message: message_hash)
      message = result.body.dig(:get_message_response, :message)

      raise RequestError, message[:fault][:message] if message[:fault].present?

      token = message.dig(:auth_response, :result, :token)
      expired_at = message.dig(:auth_response, :result, :expire_time)

      return if token.blank?

      put_token!(token, expired_at)
      token
    end

    private

    def namespaces
      super.merge(
        'xmlns:tns' => 'urn://x-artefacts-gnivc-ru/ais3/kkt/AuthService/types/1.0',
        'targetNamespace' => 'urn://x-artefacts-gnivc-ru/ais3/kkt/AuthService/types/1.0'
      )
    end

    def uri
      '/open-api/AuthService/0.1?wsdl'
    end

    def message_hash
      {
        'Message' => {
          'tns:AuthRequest' => {
            'tns:AuthAppInfo' => {
              'tns:MasterToken' => configuration.fnsapi_master_key
            }
          }
        }
      }
    end

    def put_token!(token, expired_at)
      if redis
        redis.set(configuration.redis_key, token)
        redis.expireat(configuration.redis_key, expired_at.to_i)
      else
        tmp_credentials.write_token(token, expired_at)
      end
    end
  end
end
