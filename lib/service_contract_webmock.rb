require "service_contract_webmock/version"
require "service_contract_webmock/field"
require "service_contract_webmock/contract_matcher"
require "service_contract_webmock/service_mock"

module ServiceContractWebmock
  def self.webmock!(name, resources, contract, base_url)
    ServiceMock.new(name, resources, contract, base_url).webmock!
  end
end
