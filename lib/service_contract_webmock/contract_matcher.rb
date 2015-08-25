require 'cgi'
require 'avro'

module ServiceContractWebmock
  class ContractMatcher
    attr_reader :endpoint, :resources

    def initialize(endpoint, resources)
      @endpoint = endpoint
      @resources = resources
    end

    INT = Avro::Schema::PrimitiveSchema.new(:int)

    def to_regex
      params = fields_and_pagination.map do |field|
        "#{field.name}=#{field.value}&?"
      end.join("|")
      "(#{params})+"
    end

    def fields_and_pagination
      fields + pagination_fields
    end

    def pagination_fields
      [Field.new('page', INT), Field.new('per_page', INT)]
    end

    def fields
      @fields ||= endpoint.parameters.map do |param|
        param.type.definition.fields.map do |field|
          Field.new(field.name, field.type) unless ['page', 'per_page'].include?(field.name)
        end
      end.flatten.compact
    end

    def field_int?(name)
      fields.detect {|f| f.name == name}.try(:int?)
    end

    def extract_request(query)
      params = CGI.parse(query)
      fields.select {|field| field.name.in?(params.keys)}.each_with_object({}) do |field, acc|
        data = params[field.name][0].split(',').flat_map {|value| field.convert(value)}
        acc[field.name] = data
      end
    end

    def found(query)
      search = extract_request(query)
      if search.empty?
        resources
      else
        resources.select do |resource|
          search.all? do |key, data|
            key = "id" if key == "ids"
            resource[key].in?(data)
          end
        end
      end
    end
  end
end
