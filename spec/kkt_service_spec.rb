# frozen_string_literal: true

RSpec.describe Fnsapi::KktService do
  before do
    allow_any_instance_of(Fnsapi::Configuration).to receive(:fnsapi_master_key).and_return('test_key')
    allow(Fnsapi::TmpStorage).to receive(:new).and_return(StubbedTmpStorage.new)
    allow_any_instance_of(Fnsapi::AuthService).to receive(:reset_credentials).and_return('token')
  end

  let(:instance) { described_class.new }
  let(:correct_namespaces) do
    {
      'xmlns:xs' => 'http://www.w3.org/2001/XMLSchema',
      'xmlns:tns' => 'urn://x-artefacts-gnivc-ru/ais3/kkt/KktTicketService/types/1.0',
      'targetNamespace' => 'urn://x-artefacts-gnivc-ru/ais3/kkt/KktTicketService/types/1.0'
    }
  end
  let(:purchase_date) { DateTime.now }
  let(:ticket) do
    OpenStruct.new(
      fn: '123',
      fd: '456',
      pfd: '789',
      purchase_date: purchase_date,
      amount_cents: 100_500
    )
  end
  let(:ticket_hash) do
    {
      'tns:Fn' => ticket.fn,
      'tns:FiscalDocumentId' => ticket.fd,
      'tns:FiscalSign' => ticket.pfd,
      'tns:Date' => ticket.purchase_date.strftime('%FT%T'),
      'tns:Sum' => ticket.amount_cents,
      'tns:TypeOperation' => 1
    }
  end

  describe '#client' do
    let(:client) { instance.client }
    let(:options) { client.globals.instance_variable_get(:@options) }

    it 'initializes Savon client instance' do
      expect(client).to be_kind_of(Savon::Client)
    end

    it 'contains correct namespaces' do
      expect(options[:namespaces]).to eq(correct_namespaces)
    end
  end

  shared_examples 'kkt_service_with_auth_params' do
    context 'when token is not defined' do
      let(:params) { [ticket] }
      before do
        allow_any_instance_of(Fnsapi::GetMessageService).to(
          receive(:call).and_return(processing_status: 'COMPLETED', message: get_message_result)
        )
      end

      it 'calls reset_credentials from AuthService' do
        expect_any_instance_of(Fnsapi::AuthService).to receive(:reset_credentials) { 'some token' }
        subject
      end
    end

    context 'when token is defined' do
      before do
        allow_any_instance_of(StubbedTmpStorage).to receive(:token) { 'token' }
        allow_any_instance_of(Fnsapi::GetMessageService).to(
          receive(:call).and_return(processing_status: 'COMPLETED', message: get_message_result)
        )
      end

      let(:params) { [ticket, 123] }

      it 'calls :get_message with correct parameters' do
        expect_any_instance_of(Savon::Client).to(
          receive(:call).with(:send_message, message: correct_message_hash).and_return(stubbed_response)
        )
        subject
      end

      it 'calls GetMessageService with correct params' do
        expect_any_instance_of(Fnsapi::GetMessageService).to receive(:call).with('test_id', 123)
        subject
      end

      context 'when user is not specified' do
        let(:params) { [ticket] }

        it 'initializes client with auth_params' do
          expect(Savon).to receive(:client).with(
            hash_including(
              headers: {
                'FNS-OpenApi-Token' => 'token',
                'FNS-OpenApi-UserToken' => Base64.strict_encode64('default_user'.to_s)
              }
            )
          ).and_call_original
          subject
        end
      end

      context 'when user is specified' do
        it 'initializes client with auth_params' do
          expect(Savon).to receive(:client).with(
            hash_including(
              headers: {
                'FNS-OpenApi-Token' => 'token',
                'FNS-OpenApi-UserToken' => Base64.strict_encode64(123.to_s)
              }
            )
          ).and_call_original
          subject
        end
      end

      context 'when processing_status is not COMPLETED' do
        before do
          allow_any_instance_of(Fnsapi::GetMessageService).to(
            receive(:call).and_return(processing_status: 'PROCESSED', message: get_message_result)
          )
        end

        # it 'retries 5 times' do
        #   expect_any_instance_of(Fnsapi::GetMessageService).to receive(:call)
        #   subject
        # end

        it 'raises Timeout exception' do
          expect { subject }.to raise_exception(Fnsapi::RequestError, 'Timeout reached')
        end
      end
    end
  end

  describe '#check_data' do
    let(:correct_message_hash) do
      {
        'Message' => {
          'tns:CheckTicketRequest' => {
            'tns:CheckTicketInfo' => ticket_hash
          }
        }
      }
    end
    let(:stubbed_response) do
      OpenStruct.new(
        body: {
          send_message_response: {
            message_id: 'test_id'
          }
        }
      )
    end
    let(:get_message_result) do
      {
        check_ticket_response: {
          result: {
            code: '200',
            ticket: ticket_hash.to_json
          }
        }
      }
    end

    before do
      allow_any_instance_of(Savon::Client).to receive(:call) { stubbed_response }
    end

    subject { instance.check_data(*params) }

    it_behaves_like 'kkt_service_with_auth_params'

    context 'when token is defined' do
      before do
        allow_any_instance_of(StubbedTmpStorage).to receive(:token) { 'token' }
        allow_any_instance_of(Fnsapi::GetMessageService).to(
          receive(:call).and_return(processing_status: 'COMPLETED', message: get_message_result)
        )
      end

      let(:params) { [ticket, 123] }

      it 'returns true' do
        expect(subject).to eq(true)
      end
    end
  end

  describe '#get_data' do
    let(:correct_message_hash) do
      {
        'Message' => {
          'tns:GetTicketRequest' => {
            'tns:GetTicketInfo' => ticket_hash
          }
        }
      }
    end
    let(:stubbed_response) do
      OpenStruct.new(
        body: {
          send_message_response: {
            message_id: 'test_id'
          }
        }
      )
    end
    let(:get_message_result) do
      {
        get_ticket_response: {
          result: {
            code: '200',
            ticket: ticket_hash.to_json
          }
        }
      }
    end

    before do
      allow_any_instance_of(Savon::Client).to receive(:call) { stubbed_response }
    end

    subject { instance.get_data(*params) }

    it_behaves_like 'kkt_service_with_auth_params'

    context 'when token is defined' do
      before do
        allow_any_instance_of(StubbedTmpStorage).to receive(:token) { 'token' }
        allow_any_instance_of(Fnsapi::GetMessageService).to(
          receive(:call).and_return(processing_status: 'COMPLETED', message: get_message_result)
        )
      end

      let(:params) { [ticket, 123] }

      it 'returns ticket' do
        expect(subject).to eq(ticket_hash)
      end

      context 'when message code is not 200' do
        let(:get_message_result) do
          {
            get_ticket_response: {
              result: { code: '400' }
            }
          }
        end
        it 'returns code' do
          expect(subject).to eq('400')
        end
      end
    end
  end
end
