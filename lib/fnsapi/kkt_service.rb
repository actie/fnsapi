# frozen_string_literal: true

module Fnsapi
  class KktService < BaseService
    include KktConcern

    SUCCESS_STATUS_CODES = %w(200).freeze

    def check_data(object, user_id = 'default_user')
      ticket = Ticket.new(object)
      result = client(auth_params(user_id)).call(:send_message, message: check_ticket_hash(ticket))
      message_id = result.body.dig(:send_message_response, :message_id)

      message = parse_message(message_id, user_id)
      return unless message

      code = message.dig(:check_ticket_response, :result, :code)
      code == '200'
    end

    def get_data(object, user_id = 'default_user')
      ticket = Ticket.new(object)
      result = client(auth_params(user_id)).call(:send_message, message: get_ticket_hash(ticket))
      message_id = result.body.dig(:send_message_response, :message_id)

      message = parse_message(message_id, user_id)
      return unless message

      code = message.dig(:get_ticket_response, :result, :code)
      handle_response(code)

      JSON.parse(message.dig(:get_ticket_response, :result, :ticket))
    end

    private

    def parse_message(message_id, user_id)
      wait_time = 0
      i = 0

      while true do
        response = GetMessageService.new.call(message_id, user_id)
        return response[:message] if response[:processing_status] == 'COMPLETED'

        timeout = (2**i - 1)/2
        wait_time += timeout
        i += 1

        break if wait_time > Fnsapi.configuration.get_message_timeout

        sleep(timeout)
      end

      raise RequestError, 'Timeout reached'
    end

    def namespaces
      super.merge(
        'xmlns:tns' => 'urn://x-artefacts-gnivc-ru/ais3/kkt/KktTicketService/types/1.0',
        'targetNamespace' => 'urn://x-artefacts-gnivc-ru/ais3/kkt/KktTicketService/types/1.0'
      )
    end

    def check_ticket_hash(ticket)
      {
        'Message' => {
          'tns:CheckTicketRequest' => {
            'tns:CheckTicketInfo' => ticket_hash(ticket)
          }
        }
      }
    end

    def get_ticket_hash(ticket)
      {
        'Message' => {
          'tns:GetTicketRequest' => {
            'tns:GetTicketInfo' => ticket_hash(ticket)
          }
        }
      }
    end

    def ticket_hash(ticket)
      {
        'tns:Fn' => ticket.fn,
        'tns:FiscalDocumentId' => ticket.fd,
        'tns:FiscalSign' => ticket.pfd,
        'tns:Date' => ticket.purchase_date.strftime('%FT%T'),
        'tns:Sum' => ticket.amount_cents,
        'tns:TypeOperation' => 1
      }
    end

    def handle_response(code)
      return if SUCCESS_STATUS_CODES.include?(code)

      case code
      when '400'
        raise ::Fnsapi::FnsBadRequestError
      when '404'
        raise ::Fnsapi::FnsNotFoundError
      when '406'
        raise ::Fnsapi::FnsCryptoProtectionError
      when '503'
        raise ::Fnsapi::FnsServiceUnaviableError
      else
        raise ::Fnsapi::FnsUnknownError
      end
    end
  end
end
