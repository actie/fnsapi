# frozen_string_literal: true

RSpec.describe Fnsapi::TmpStorage do
  class StubbedFile
    def truncate(_); end
    def write(_); end
    def rewind; end
    def read; end
  end

  let(:instance) { described_class.new }

  before { allow(File).to receive(:open).and_return(StubbedFile.new) }

  it 'opens a file' do
    instance
    expect(File).to have_received(:open).once
  end

  context 'when Rails is not defined' do
    it 'uses local tmp dir' do
      instance
      expect(File).to have_received(:open).with('tmp/fnsapi_tmp_credentials', 'a+')
    end
  end

  context 'when Rails is defined' do
    before do
      class Rails; end

      allow(Rails).to receive(:root).and_return(Pathname.new('/rails'))
      allow_any_instance_of(Pathname).to receive(:join).and_return('/rails/tmp/fnsapi_tmp_credentials')
    end

    after { Object.send(:remove_const, :Rails) }

    it 'creates file in Rails tmp dir' do
      expect_any_instance_of(Pathname).to receive(:join).with('tmp', 'fnsapi_tmp_credentials')
      instance
      expect(File).to have_received(:open).with('/rails/tmp/fnsapi_tmp_credentials', 'a+')
    end
  end

  describe '#write_token' do
    subject(:write_token) { instance.write_token(token, expire_at) }
    let(:token_string) { { token: token, expire_at: expire_at }.to_json }
    let(:token) { 'token' }
    let(:expire_at) { Time.now }

    it 'clears file' do
      expect_any_instance_of(StubbedFile).to receive(:truncate).with(0)
      write_token
    end

    it 'writes new data in file' do
      expect_any_instance_of(StubbedFile).to receive(:write).with(token_string)
      write_token
    end

    it 'rewinds file' do
      expect_any_instance_of(StubbedFile).to receive(:rewind)
      write_token
    end
  end

  describe '#token' do
    before { allow_any_instance_of(StubbedFile).to receive(:read).and_return(token_string) }

    let(:token_string) { { token: token, expire_at: expire_at }.to_json }
    let(:token) { 'token' }

    context 'when not expired' do
      let(:expire_at) { DateTime.now + 100_000 }

      it 'returns token' do
        expect(instance.token).to eq('token')
      end
    end

    context 'when expired' do
      let(:expire_at) { DateTime.now - 100_000 }

      it 'returns nil' do
        expect(instance.token).to eq(nil)
      end
    end

    context 'when JSON string invalid' do
      let(:token_string) { '' }

      it 'returns nil' do
        expect(instance.token).to eq(nil)
      end
    end
  end
end
