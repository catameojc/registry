FactoryGirl.define do
  factory :partner_pricing do
    action 'domain_create'
    period 1
    price 35.00.money
  end
end
