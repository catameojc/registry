REGISTER_DOMAIN = Transform /^register a domain(?: |)(.*?)$/ do |scenario|
  build_request scenario: scenario, resource: :order, action: :register_domain
end

When /^I (#{REGISTER_DOMAIN})$/ do |request|
  create :contact

  stub_request(:post, SyncOrderJob::URL)
    .with(headers: headers, body: request.body)
    .to_return status: 201

  post orders_path, request.json
end

Then /^domain must be registered$/ do
  json_response.must_equal 'order/register_domain_response'.json

  Domain.exists? name: DOMAIN
end

Then /^domain with two-level TLD must be registered$/ do
  json_response.must_equal 'order/register_domain_with_two_level_tld_response'.json

  Domain.exists? name: TWO_LEVEL_DOMAIN
end

Then /^register domain fee must be deducted$/ do
  assert_fee_deducted 70.00.money
end

Then /^order must be synced to other systems$/ do
  assert_requested :post, SyncOrderJob::URL, times: 1
end
