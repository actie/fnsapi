# frozen_string_literal: true

module Fnsapi
  class GetMessageService < BaseService
    include KktConcern

    def call(message_id, user_id = 'default_user')
      result = client(auth_params(user_id)).call(:get_message, message: message_hash(message_id))
      result.body.dig(:get_message_response)
    end

    private

    def namespaces
      super.merge(
        'xmlns:tns' => 'urn://x-artefacts-gnivc-ru/inplat/servin/OpenApiAsyncMessageConsumerService/types/1.0'
      )
    end

    def message_hash(message_id)
      { 'tns:MessageId' => message_id }
    end
  end
end
