# frozen_string_literal: true

module Fnsapi
  class TmpStorage
    def initialize
      @file = File.open(file_path, 'a+')
    end

    def write_token(token, expire_at)
      @file.truncate(0)
      @file.write({ token: token, expire_at: expire_at }.to_json)
      @file.rewind
    end

    def token
      @file = File.open(file_path, 'a+')
      data = JSON.parse(@file.read)
      expired_at = Time.parse(data['expire_at'])

      if expired_at < Time.now
        @file.truncate(0)
        return
      end

      data['token']
    rescue JSON::ParserError
      @file.truncate(0)
      nil
    end

    private

    def file_path
      if defined?(Rails)
        Rails.root.join('tmp', Fnsapi.configuration.tmp_file_name)
      else
        'tmp/' + Fnsapi.configuration.tmp_file_name
      end
    end
  end
end
