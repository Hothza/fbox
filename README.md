# Fbox

This gem is a [FaucetBox](https://faucetbox.com) REST API helper. It allows you
to integrate FaucetBox API in an easy way in your RubyOnRails application.

Build status: [![Build Status](https://travis-ci.org/Hothza/fbox.svg)](https://travis-ci.org/Hothza/fbox)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'fbox'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install fbox

## Usage

Fbox has four FaucetBox API releated methods:

- currencies - returns a list of currently supported coin types by FaucetBox
```ruby
    require 'pp'
    require 'fbox'
    
    api_key = '4VdBEIAQKPpZ4SWOhQLUMn7mMNVql' # FBox example API key
    fbox = Fbox::Client.new({:api_key => api_key})
    currencies = fbox.currencies()

    pp "Supported currencies: #{currencies}\n"
```

- balance(currency) - returns current balance fo given currency, if not set then BTC is used as a default one
```ruby
    require 'pp'
    require 'fbox'
    
    # Unfortunately at this moment API key used in examples on FaucetBox site
    # gives 403 status, so you have tou use your own
    
    api_key = '4VdBEIAQKPpZ4SWOhQLUMn7mMNVql' # Put your API key here
    currency = 'BTC'
    
    fbox = Fbox::Client.new({:api_key => api_key})
    balance = fbox.balance()
    pp "balance: #{balance}\n"
```

- payment(to, amount, referral = false, currency = '') - sends a given amount of coins
(in given currency, if not set than BTC is used as a default) from your faucet into destination address 

```ruby
    require 'pp'
    require 'fbox'

    api_key = ''      # Put here your API key
    address = ''      # Put here destination address (BTC, LTC, or other supported by FaucetBox)
    amount = 10       # Amount of satoshis to send
    referral = false  # Is this a referral payment?
    
    fbox = Fbox::Client.new({:api_key => api_key})
    payment = fbox.payment(address, amount, referral)
    pp "payment: #{payment}\n"
```

- payouts(count = 1, currency = '') - returns list of payouts (no more than 10)
from last 30 days for given currency (if not set than BTC is used as a default one)
*WARNING:* This API call gives timeouts - use with care (it is probably disabled on FaucetBox)


There are also two helper methods:

- is_response_ok?(body) - returns true if FaucetBox respone has status: 200
- is_address_valid?(address) - checks if given coin address is valid (proper length, correct checksum, etc.)


## Contributing

1. Fork it ( https://github.com/Hothza/fbox/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
