# frozen_string_literal: true

module Fnsapi
  class TmpCredentials
    def initialize
      @file = File.open(Rails.root.join('tmp', configuration.tmp_file_name), 'a+')
    end

    def write_token(token, expire_at)
      @file.truncate(0)
      @file.write({ token: token, expire_at: expire_at }.to_json)
      @file.rewind
    end

    def token
      data = JSON.parse(@file.read)
      expired_at = Time.zone.parse(data['expired_at'])

      if expired_at < Time.current
        @file.truncate(0)
        return
      end

      data['token']
    rescue JSON::ParserError
      @file.truncate(0)
      nil
    end
  end
end
