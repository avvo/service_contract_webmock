require 'rack'
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
      yield self if block_given?
    end

    def stub_request(method, path)
      WebMock.stub_request(method, %r{#{base_url}/#{path}})
    end

    def stub_index_request
      stub_request(:get, "#{name}\\.json\\??$")
        .to_return do |request|
          {
            body: {
              name => apply_pagination(request, resources),
              meta: pagination_meta(request, resources).merge({ status: 200 })
            }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          }
        end
    end

    def stub_show_request
      return if contract.endpoint("show").nil?
      key = contract.endpoint("show").parameters.first.name
      stub_request(:get, "#{name}/\\d+\\.json").
        to_return do |request|
          id = request.uri.path.scan(/\/(\d+)\.json/)[0][0].to_i
          found = resources.select {|r| r[key] == id}

          if found.present?
            {
              body: { name => found, meta: { status: 200 } }.to_json,
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
          found = matcher.found(request.uri.query)
          {
            body: {
              name => apply_pagination(request, found),
              meta: pagination_meta(request, found).merge({ status: 200})
            }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          }
        end
    end

    private
    def apply_pagination(request, resources)
      pagination_params = extract_pagination_params(request.uri.query, resources)
      per_page = pagination_params["per_page"].to_i
      current_page = pagination_params["page"].to_i

      resources.slice(((current_page - 1) * per_page), per_page) || []  # Array#slice returns nil when index is out of bounds
    end

    def pagination_meta(request, resources)
      pagination_params = extract_pagination_params(request.uri.query, resources)
      per_page = pagination_params["per_page"].to_i
      total_pages = resources.count / per_page
      total_pages += 1 if resources.count % per_page > 0

      {
        current_page: pagination_params["page"].to_i,
        per_page: per_page,
        total_pages: total_pages,
        total_entries: resources.count
      }
    end

    def extract_pagination_params(query, resources)
      params = Rack::Utils.parse_nested_query(query).slice("page", "per_page")
      params["page"] = 1 if params["page"].nil? || params["page"].empty?
      params["per_page"] = [resources.count, 1].max if params["per_page"].nil? || params["per_page"].empty?

      params
    end
  end
end
