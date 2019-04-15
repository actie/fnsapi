# frozen_string_literal: true

module FnsApi
  module KktConcern
    def auth_params(user)
      refresh_credentials! unless token

      { headers: { 'FNS-OpenApi-Token' => token, 'FNS-OpenApi-UserToken' => Base64.strict_encode64(user.id.to_s) } }
    end

    def uri
      '/open-api/ais3/KktService/0.1?wsdl'
    end

    def refresh_credentials!
      AuthService.new.reset_credentials
    end
  end
end
