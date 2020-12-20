# frozen_string_literal: true

RSpec.describe Fnsapi::Configuration do
  let(:config) { described_class.new }

  describe 'readers' do
    it 'returns correct value for fns_host' do
      expect(config.fns_host).to eq('https://openapi.nalog.ru')
    end

    it 'returns correct value for fns_port' do
      expect(config.fns_port).to eq(8090)
    end

    it 'returns correct value for redis_key' do
      expect(config.redis_key).to eq(:fnsapi_token)
    end

    it 'returns correct value for redis_url' do
      expect(config.redis_url).to eq(nil)
    end

    it 'returns correct value for tmp_file_name' do
      expect(config.tmp_file_name).to eq('fnsapi_tmp_credentials')
    end

     it 'returns correct value for get_message_timeout' do
      expect(config.get_message_timeout).to eq(60)
    end

    it 'returns correct value for log_enabled' do
      expect(config.log_enabled).to eq(false)
    end

    it 'returns correct value for logger' do
      expect(config.logger).to be_a(Logger)
    end

    it 'returns correct value for default proxy url' do
      expect(config.proxy_url).to be_nil
    end

    context 'when used in Rails app' do
      before do
        class Rails; end

        allow(Rails).to receive(:logger).and_return(Logger.new($stdout))
      end

      after { Object.send(:remove_const, :Rails) }

      it 'uses Rails.logger' do
        expect(Rails).to receive(:logger)
        expect(config.logger).to be_a(Logger)
      end
    end
  end

  describe 'writers' do
    it 'changes value for fns_host' do
      expect { config.fns_host = 'test' }.to change { config.fns_host }.from('https://openapi.nalog.ru').to('test')
    end

    it 'changes value for fns_port' do
      expect { config.fns_port = 1234 }.to change { config.fns_port }.from(8090).to(1234)
    end

    it 'changes value for redis_key' do
      expect { config.redis_key = 'test' }.to change { config.redis_key }.from(:fnsapi_token).to('test')
    end

    it 'changes value for redis_url' do
      expect { config.redis_url = 'test' }.to change { config.redis_url }.from(nil).to('test')
    end

    it 'changes value for tmp_file_name' do
      expect { config.tmp_file_name = 'test' }.to(
        change { config.tmp_file_name }.from('fnsapi_tmp_credentials').to('test')
      )
    end

    it 'changes value for log_enabled' do
      expect { config.log_enabled = true }.to(
        change { config.log_enabled }.from(false).to(true)
      )
    end

    it 'changes value for logger' do
      expect { config.logger = Logger.new($stdout) }.to(change { config.logger })
    end

    it 'changes value for get_message_timeout' do
      expect { config.get_message_timeout = 10 }.to(
        change { config.get_message_timeout }.from(60).to(10)
      )
    end

    it 'changes value for fnsapi_master_key' do
      config.fnsapi_master_key = 'test'
      expect(config.fnsapi_master_key).to eq('test')
    end

    it 'changes value for fnsapi_user_token' do
      config.fnsapi_user_token = 'test'
      expect(config.fnsapi_user_token).to eq('test')
    end

    it 'changes value for proxy_url' do
      expect { config.proxy_url = 'http://user:pass@host' }.to(
        change { config.proxy_url }.from(nil).to('http://user:pass@host')
      )
    end
  end

  describe 'required attributes' do
    it 'raises exception if fnsapi_master_key is not defined' do
      expect { config.fnsapi_master_key }.to raise_error(Fnsapi::InvalidConfigurationError)
    end

    it 'raises exception if fnsapi_user_token is not defined' do
      expect { config.fnsapi_user_token }.to raise_error(Fnsapi::InvalidConfigurationError)
    end
  end
end
