# frozen_string_literal: true

RSpec.describe Fnsapi::AuthService do
  before do
    allow_any_instance_of(Fnsapi::Configuration).to receive(:fnsapi_master_key).and_return('test_key')
    allow(Fnsapi::TmpStorage).to receive(:new).and_return(StubbedTmpStorage.new)
  end

  let(:instance) { described_class.new }
  let(:correct_namespaces) do
    {
      'xmlns:xs' => 'http://www.w3.org/2001/XMLSchema',
      'xmlns:tns' => 'urn://x-artefacts-gnivc-ru/ais3/kkt/AuthService/types/1.0',
      'targetNamespace' => 'urn://x-artefacts-gnivc-ru/ais3/kkt/AuthService/types/1.0'
    }
  end
  let(:correct_message_hash) do
    {
      'Message' => {
        'tns:AuthRequest' => {
          'tns:AuthAppInfo' => {
            'tns:MasterToken' => 'test_key'
          }
        }
      }
    }
  end
  let(:expired_at) { Time.now }
  let(:stubbed_response) do
    OpenStruct.new(
      body: {
        get_message_response: {
          message: {
            auth_response: {
              result: {
                token: 'token',
                expire_time: expired_at.to_s
              }
            }
          }
        }
      }
    )
  end

  describe '#client' do
    let(:client) { instance.client }
    let(:options) { client.globals.instance_variable_get(:@options) }

    it 'initializes Savon client instance' do
      expect(client).to be_kind_of(Savon::Client)
    end

    it 'contains correct wsdl' do
      expect(options[:wsdl]).to eq('https://openapi.nalog.ru:8090/open-api/AuthService/0.1?wsdl')
    end

    it 'contains correct namespaces' do
      expect(options[:namespaces]).to eq(correct_namespaces)
    end
  end

  describe '#reset_credentials' do
    before do
      allow_any_instance_of(Savon::Client).to receive(:call) { stubbed_response }
    end

    subject(:reset_credentials) { instance.reset_credentials }

    it 'calls :get_message with correct parameters' do
      expect_any_instance_of(Savon::Client).to(
        receive(:call).with(:get_message, message: correct_message_hash).and_return(stubbed_response)
      )
      reset_credentials
    end

    it 'returns token' do
      expect(reset_credentials).to eq('token')
    end

    context 'when there is fault message' do
      before do
        allow_any_instance_of(Savon::Client).to receive(:call) do
          OpenStruct.new(
            body: {
              get_message_response: {
                message: {
                  fault: {
                    message: 'fault_message'
                  }
                }
              }
            }
          )
        end
      end

      it 'raises RequestError with this message' do
        expect { reset_credentials }.to raise_exception(Fnsapi::RequestError, 'fault_message')
      end
    end

    context 'when redis_url is defined' do
      before do
        allow_any_instance_of(Fnsapi::Configuration).to receive(:redis_url).and_return('redis_url')
      end

      it 'initializes redis object' do
        expect(Redis).to receive(:new).with(url: 'redis_url')
        reset_credentials
      end

      it 'saves token to redis' do
        expect_any_instance_of(Redis).to receive(:set).with(:fnsapi_token, 'token')
        reset_credentials
      end

      it 'sets expired_at in redis' do
        expect_any_instance_of(Redis).to receive(:expireat).with(:fnsapi_token, expired_at.to_i)
        reset_credentials
      end
    end

    context 'when redis_url is not defined' do
      it 'initializes TmpStorage object' do
        expect(Fnsapi::TmpStorage).to receive(:new).and_return(StubbedTmpStorage.new)
        reset_credentials
      end

      it 'saves token to tmp_storage' do
        expect_any_instance_of(StubbedTmpStorage).to receive(:write_token).with('token', Time.at(expired_at.to_i))
        reset_credentials
      end
    end
  end
end
