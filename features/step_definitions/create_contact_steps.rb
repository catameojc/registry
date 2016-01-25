When /^I create a new contact$/ do
  stub_request(:post, SyncCreateContactJob::URL).to_return(status: 201)

  post contacts_path, 'contact/post_request'.json
end

When /^I create a new contact for another partner$/ do
  stub_request(:post, SyncCreateContactJob::URL).to_return(status: 201)

  post contacts_path, 'contact/admin_post_request'.json
end

When /^I create a new contact with empty request$/ do
  post contacts_path, 'contact/post_with_empty_request_request'.json
end

When /^I create a new contact under another partner$/ do
  post contacts_path, 'contact/post_under_another_partner_request'.json
end

Then /^contact must be created$/ do
  last_response.status.must_equal 201

  json_response.must_equal 'contact/post_response'.json

  Contact.count.must_equal 1
  Contact.last.contact_histories.count.must_equal 1
end