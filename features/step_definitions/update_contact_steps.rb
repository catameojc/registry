UPDATE_CONTACT = Transform /^update a contact(?: |)(.*?)$/ do |scenario|
  build_request scenario: scenario, resource: :contact, action: :patch
end

When /^I (#{UPDATE_CONTACT})$/ do |request|
  contact = create :contact

  patch contact_path(contact.handle), request.json
end

When /^I update a contact that does not exist$/ do
  contact = build :contact

  patch contact_path(contact.handle), 'contact/patch_request'.json
end

Then /^contact must be updated$/ do
  last_response.status.must_equal 200

  json_response.must_equal 'contact/patch_response'.json

  Contact.count.must_equal 1
  Contact.last.contact_histories.count.must_equal 2
end
