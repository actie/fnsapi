# frozen_string_literal: true

module FnsApi
  class KktService < BaseService
    include KktConcern

    def check_data(ticket, user)
      result = client(auth_params(user)).call(:send_message, message: check_ticket_hash(ticket))
      message_id = result.body.dig(:send_message_response, :message_id)

      message = parse_message(message_id, user)
      return unless message

      code = message.dig(:check_ticket_response, :result, :code)
      code == '200'
    end

    def get_data(ticket, user)
      result = client(auth_params(user)).call(:send_message, message: get_ticket_hash(ticket))
      message_id = result.body.dig(:send_message_response, :message_id)

      message = parse_message(message_id, user)
      return unless message

      code = message.dig(:get_ticket_response, :result, :code)
      return code if code != '200'

      JSON.parse(message.dig(:get_ticket_response, :result, :ticket)).deep_symbolize_keys
    end

    private

    def parse_message(message_id, user)
      5.times do |i|
        response = GetMessageService.new.call(message_id, user)
        return response[:message] if response[:processing_status] == 'COMPLETED'

        sleep(i)
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
        'tns:Date' => ticket.purchase_date.in_time_zone('Europe/Moscow').strftime('%FT%T'),
        'tns:Sum' => ticket.amount_cents,
        'tns:TypeOperation' => 1
      }
    end
  end
end
