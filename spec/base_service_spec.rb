# frozen_string_literal: true

RSpec.describe Fnsapi::BaseService do
  before do
    allow_any_instance_of(Fnsapi::Configuration).to receive(:fnsapi_master_key).and_return('test_key')
    allow_any_instance_of(Fnsapi::Configuration).to receive(:log_enabled).and_return(true)
    allow(Fnsapi::TmpStorage).to receive(:new).and_return(StubbedTmpStorage.new)
    allow_any_instance_of(Fnsapi::BaseService).to receive(:uri) { '/base_uri' }
  end

  let(:instance) { described_class.new }
  let(:correct_namespaces) do
    { 'xmlns:xs' => 'http://www.w3.org/2001/XMLSchema' }
  end

  describe '#client' do
    let(:client) { instance.client }
    let(:options) { client.globals.instance_variable_get(:@options) }

    it 'initializes Savon client instance' do
      expect(client).to be_kind_of(Savon::Client)
    end

    it 'contains correct wsdl' do
      expect(options[:wsdl]).to eq('https://openapi.nalog.ru:8090/base_uri')
    end

    it 'contains correct namespaces' do
      expect(options[:namespaces]).to eq(correct_namespaces)
    end

    it 'contains correct env_namespace' do
      expect(options[:env_namespace]).to eq(:soap)
    end

    it 'contains log configuration' do
      expect(options[:log]).to eq(true)
    end

    it 'contains logger configuration' do
      expect(options[:logger]).to be_a(Logger)
    end
  end
end
