# Paylike 💱

Ruby SDK for working with [Paylike](https://github.com/paylike/api-docs)
Payments services.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'paylike.rb'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install paylike.rb

## Usage

A subset of the Paylike resources are provided with this SDK:

 * `Paylike::App`
 * `Paylike::Card`
 * `Paylike::Line`
 * `Paylike::User`
 * `Paylike::Transaction`

These resources have implemented the _CRUD_ methods to allow API operations:
 * `all`
 * `find`
 * `create`
 * `update`
 * `delete`

Here's an example on how to create a transaction, capture it, and refund it:
```ruby
require 'paylike'

trans = Paylike::Transaction.create(
  currency: 'EUR',
  amount: 1000,
  card: {
    number: '4100000000000000',
    code: '123',
    expiry: {
      month: '08',
      year: '2020'
    }
  }
)
trans.capture(amount: 1000)
trans.refund(amount: 500)
```

### Configuration

The API keys will be loaded from your environment variables:

 * `PAYLIKE_KEY`
 * `PAYLIKE_MERCHANT_ID`
 * `PAYLIKE_PUBLIC_KEY`

## Development

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release`, which will create a git tag for the version, push
git commits and tags, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/luneteyewear/paylike. This project is intended to be a safe,
welcoming space for collaboration, and contributors are expected to adhere to
the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT
License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Paylike project’s codebases, issue trackers, chat
rooms and mailing lists is expected to follow the [code of
conduct](https://github.com/luneteyewear/paylike/blob/master/CODE_OF_CONDUCT.md).
