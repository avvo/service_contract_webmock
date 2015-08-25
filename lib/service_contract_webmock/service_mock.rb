require 'webmock'

module ServiceContractWebmock
  class ServiceMock
    attr_reader :name, :resources, :contract, :base_url

    def initialize(name, resources, contract, base_url)
      @name = name
      @resources = resources
      @contract = contract
      @base_url = base_url
    end

    def webmock!
      stub_index_request
      stub_search_request
      stub_show_request
    end

    def stub_request(method, path)
      WebMock.stub_request(method, %r{#{base_url}/#{path}})
    end

    def stub_index_request
      stub_request(:get, "#{name}\\.json\\??$")
        .to_return(body: { name => resources }.to_json,
                  headers: { 'Content-Type' => 'application/json' })
    end

    def stub_show_request
      key = contract.endpoint("show").parameters.first.name
      stub_request(:get, "#{name}/\\d+\\.json").
        to_return do |request|
          id = request.uri.path.scan(/\/(\d+)\.json/)[0][0].to_i
          found = resources.select {|r| r[key] == id}

          if found.present?
            {
              body: { name => found }.to_json,
              headers: { 'Content-Type' => 'application/json' }
            }
          else
            {
              body: { meta: { status: 404, errors: ['resource not found'] } }.to_json,
              headers: { 'Content-Type' => 'application/json' },
              status: 404
            }
          end
        end
    end

    def stub_search_request
      matcher = ContractMatcher.new(contract.endpoint("index"), resources)
      stub_request(:get, "#{name}\\.json\\?#{matcher.to_regex}").
        to_return do |request|
          {
            body: { name => matcher.found(request.uri.query) }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          }
        end
    end
  end
end
