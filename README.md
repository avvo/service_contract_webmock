# ServiceContractWebmock

A library for taking Avro contracts from ServiceContract and generating Webmock
HTTP mocks to return fixture data.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'service_contract_webmock'
```

## Usage

Have some mocks for a service, like:

```yaml
# spec/mocks/foobar/orders.yml
---
- id: 1
  customer_id: 1
  status: Fulfilled
```

And assuming the `Foobar::Contract` has a schema defined for `Order`, then the
following will create webmocks to return the order fixture.

```ruby
    ledger_contract = Foobar::Contract::Service.find("v1")
    base_url = 'http://localhost:6002/api/v1'

    Dir['spec/mocks/foobar/*.yml'].each do |filename|
      name = File.basename(filename, '.yml')
      resources = YAML.load_file(File.join(Rails.root, filename))
      controller = ledger_contract.protocol(name.singularize)
      next if controller.nil?

      ServiceContractWebmock.webmock!(name, resources, controller, base_url)
    end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`rake rspec` to run the tests. You can also run `bin/console` for an
interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release`, which will create a git tag for the version, push
git commits and tags, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/[USERNAME]/service_contract_webmock.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

