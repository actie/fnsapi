# Fnsapi

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/fnsapi`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'fnsapi', git: 'https://github.com/actie/fnsapi.git'
```
Maybe later we will release it on rubygems to.

And then execute:

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
And if you want to store temporrary credentials in redis specify `redis_url`. If you don't they will be stored in tmp file.

All other configurations have default values, but you can change them. The full parameters list:
```
fns_host
fns_port
redis_key
redis_url
tmp_file_name
fnsapi_user_token
fnsapi_master_key
```

## Usage

There are two main methods:
```ruby
Fnsapi::KktService.new.check_data(ticket, user_id)
Fnsapi::KktService.new.get_data(ticket, user_id)
```
The first one checks if your data is correct and returns `true` or `false`. The second one returns the tickets data from FNS if your tickets data is correct (it's strange that you should send most parts of data that you want to receive, but it's the API we have)

`ticket` should be an object which implements several methods:

```
fn - Fiscal number
fd - Fiscal document id
pfd - Fiscal signature
purchase_date - Ticket purchase date with time (we have tested for Moscow timezone but this point is not documented, and FNS API don't acept time with timezone, so I don't sure what timezone can you use.)
amount_cents - Ticket amount (integer) in cents
```

`user_id` - is an optional parameter. You can send the indentificator for user in you system if you want to specify which person do this request. In other way it has a default value `'default_user'`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/actie/fnsapi.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
