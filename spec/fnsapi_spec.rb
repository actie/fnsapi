# frozen_string_literal: true

RSpec.describe Fnsapi do
  it 'has a version number' do
    expect(described_class::VERSION).not_to be nil
  end

  describe '#configuration' do
    it 'returns and instance of Configuration class' do
      expect(described_class.configuration).to be_kind_of(Fnsapi::Configuration)
    end
  end

  describe '#configure' do
    subject(:configure) do
      described_class.configure { |config| config.fns_port = 1234 }
    end
    after { described_class.configure { |config| config.fns_port = 8090 } }

    it 'changes configuration parameters' do
      expect { configure }.to change { described_class.configuration.fns_port }.from(8090).to(1234)
    end
  end

  describe '#check_data' do
    before do
      allow_any_instance_of(Fnsapi::Configuration).to receive(:fnsapi_master_key).and_return('test_key')
    end

    it 'calls Fnsapi::KktService instance method check_data' do
      expect_any_instance_of(Fnsapi::KktService).to receive(:check_data).with('test', 123)
      described_class.check_data('test', 123)
    end
  end

  describe '#get_data' do
    before do
      allow_any_instance_of(Fnsapi::Configuration).to receive(:fnsapi_master_key).and_return('test_key')
    end

    it 'calls Fnsapi::KktService instance method get_data' do
      expect_any_instance_of(Fnsapi::KktService).to receive(:get_data).with('test', 123)
      described_class.get_data('test', 123)
    end
  end
end
