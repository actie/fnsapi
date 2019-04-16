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

    it 'changes configuration parameters' do
      expect { configure }.to change { described_class.configuration.fns_port }.from(8090).to(1234)
    end
  end
end
