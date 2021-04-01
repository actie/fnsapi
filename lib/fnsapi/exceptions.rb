# frozen_string_literal: true

# Fns Exceptions
module Fnsapi
  class Error < ::StandardError; end

  class APIError < Error; end

  # status 400
  class FnsBadRequestError < APIError
    def message
      'Не пройден форматно-логический контроль реквизитов фискальных документов'
    end
  end

  # status 404
  class FnsNotFoundError < APIError
    def message
      'Фискальный документ не найден в оперативном хранилище (сформирован более 2,5 месяцев назад)'
    end
  end

  # status 406
  class FnsCryptoProtectionError < APIError
    def message
      'Направленный фискальный признак не прошел проверку системы криптозащиты, поиск фискального документа прерван, дальнейшие попытки проверки запрещены'
    end
  end

  # status 503
  class FnsServiceUnaviableError < APIError
    def message
      'Недокументированная ошибка в работе сервиса, для выяснения причин следует обратиться в техподдержку, указав: URL запроса к сервису, текст запроса к сервису, текст ответа от сервиса.'
    end
  end

  class FnsUnknownError < APIError; end
end