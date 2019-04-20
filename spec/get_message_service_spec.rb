# frozen_string_literal: true

RSpec.describe Fnsapi::GetMessageService do
  before do
    allow_any_instance_of(Fnsapi::Configuration).to receive(:fnsapi_master_key).and_return('test_key')
    allow(Fnsapi::TmpStorage).to receive(:new).and_return(StubbedTmpStorage.new)
    allow_any_instance_of(Fnsapi::AuthService).to receive(:reset_credentials).and_return('token')
    allow_any_instance_of(StubbedTmpStorage).to receive(:token).and_return('token')
  end

  let(:instance) { described_class.new }
  let(:correct_namespaces) do
    {
      'xmlns:xs' => 'http://www.w3.org/2001/XMLSchema',
      'xmlns:tns' => 'urn://x-artefacts-gnivc-ru/inplat/servin/OpenApiAsyncMessageConsumerService/types/1.0'
    }
  end
  let(:correct_message_hash) { { 'tns:MessageId' => message_id } }
  let(:message_id) { 'test_id' }
  let(:stubbed_response) do
    OpenStruct.new(
      body: {
        get_message_response: 'test'
      }
    )
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

  describe '#call' do
    before do
      allow_any_instance_of(Savon::Client).to receive(:call) { stubbed_response }
    end

    subject(:call) { instance.call(message_id) }

    context 'when user is not specified' do
      it 'initializes client with auth_params' do
        expect(Savon).to receive(:client).with(
          hash_including(
            headers: {
              'FNS-OpenApi-Token' => 'token',
              'FNS-OpenApi-UserToken' => Base64.strict_encode64('default_user'.to_s)
            }
          )
        ).and_call_original
        call
      end
    end

    context 'when user is specified' do
      subject(:call) { instance.call(message_id, 123) }

      it 'initializes client with auth_params' do
        expect(Savon).to receive(:client).with(
          hash_including(
            headers: {
              'FNS-OpenApi-Token' => 'token',
              'FNS-OpenApi-UserToken' => Base64.strict_encode64(123.to_s)
            }
          )
        ).and_call_original
        call
      end
    end

    it 'calls :get_message with correct parameters' do
      expect_any_instance_of(Savon::Client).to(
        receive(:call).with(:get_message, message: correct_message_hash).and_return(stubbed_response)
      )
      call
    end

    it 'returns parsed response' do
      expect(call).to eq('test')
    end
  end
end
