# ServiceContractWebmock

A library for taking Avro contracts from ServiceContract and generating Webmock
HTTP mocks to return fixture data.

## Installation

Install ServiceContractWebmock from the command line:

    $ gem install service_contract_webmock --source https://avvo-gems.public.artifactory.internetbrands.com

or within a Gemfile:

    source 'https://avvo-gems.public.artifactory.internetbrands.com' do
      gem 'service_contract_webmock'
    end

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
`bundle exec rake release`, which will create a git tag for the version.

To push new versions of this gem to the Avvo Artifactory repo, a git commit will need to have a tag with a version number (e.g. v0.2.9). When a commit is pushed to Github with a version tag, this will trigger a CircleCI job that will build the gem, run any tests, and push the new gem version to Avvo Artifactory repo.

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/avvo/service_contract_webmock

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
