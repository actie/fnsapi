# Fnsapi

Gem implements API with Federal Tax services of Russia.

Гем реализуют взаимодействие с официальным апи проверки чеков Федеральной Налоговая службы России. Чтобы получить токен неоходимо подать заявку на сайте ФНС. [Документация для получения токена](https://www.nalog.ru/files/kkt/pdf/%D0%A2%D0%B5%D1%85%D0%BD%D0%B8%D1%87%D0%B5%D1%81%D0%BA%D0%B8%D0%B5%20%D1%83%D1%81%D0%BB%D0%BE%D0%B2%D0%B8%D1%8F%20%D0%B8%D1%81%D0%BF%D0%BE%D0%BB%D1%8C%D0%B7%D0%BE%D0%B2%D0%B0%D0%BD%D0%B8%D1%8F.pdf). 


[Недокументированное апи для работы с данными чеков ФНС](https://habr.com/ru/post/358966/) (при большом колиечестве проверок, работает не стабильно).

![Build Status](https://api.travis-ci.org/actie/fnsapi.svg?branch=master)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'fnsapi', github: 'actie/fnsapi'
```

Then:

    $ bundle

## Configuration

You can configure this gem in `config/initializers/fnsapi.rb`:

```ruby
Fnsapi.configure do |config|
  config.redis_url = ENV.fetch('REDIS_URL')
  config.fnsapi_master_key = ENV.fetch('FNS_API_MASTER_KEY')
  config.fnsapi_user_token = ENV.fetch('FNS_API_USER_TOKEN')
end
```

The only one parameter, which you must specify is `fnsapi_master_key`.
And if you want to store temporary credentials in redis specify `redis_url`. If you don't credentials will be stored in the tmp file.

The full parameters list for configuration with default values:
```
fns_host = 'https://openapi.nalog.ru'
fns_port = 8090
redis_key = :fnsapi_token
redis_url = nil
tmp_file_name = 'fnsapi_tmp_credentials'
fnsapi_master_key = nil
fnsapi_user_token = nil
get_message_timeout = 60
log_enabled = false
logger = Logger.new($stdout)
proxy_url = nil
```

### get message timeout

FNS provides us an asynchronous API. So, we need to make two requests: first to generate the message, and second to receive it. And there is a timeout on a server side. It's possible to download the message only within around the 60 seconds after request. We use the [exponential backoff algorithm](https://en.wikipedia.org/wiki/Exponential_backoff) with 60 seconds timeout. You can specify the different value but if it is too big, you'll just receive the TimeoutException from FNS backend.

### log_enabled

If this option id true, all SAVON logs will be written in logger.

### logger

By default it's a `stdout` stream but if you use this gem with Rails application, logger will be configurated as `Rails.logger` automaticaly.

### proxy_url

By default is not set. FNS API check requests permissions by IP address, if you have multiple servers, you can set up yor own proxy server and make requests from him.
Example: `'http://user:pass@host.domain:port'` or other formats supported by `savon gem`


## Usage

There are two methods:
```ruby
 # Is check data correct?
Fnsapi.check_data(ticket, user_id) # true / false
# Give me full information about check: products, INN etc.
Fnsapi.get_data(ticket, user_id)
```

`ticket` could be both an object which implements methods or a hash with the same keys:

```
fn - Fiscal number
fd - Fiscal document id
pfd - Fiscal signature
purchase_date - Ticket purchase date with time (we have tested for Moscow timezone but this point is not documented, and FNS API don't acept time with timezone, so I don't sure what timezone can you use.)
amount_cents - Ticket amount in cents (Integer)
```

`user_id` - is an optional parameter. You can send the ID for user in you system if you want to specify which person do this request. In other way it has a default value `'default_user'`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/actie/fnsapi.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
