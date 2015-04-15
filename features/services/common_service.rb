EMPTY_REQUEST = {}
NO_UPDATE = 'NO_UPDATE'

NON_ADMIN_PARTNER = 'alpha'
OTHER_PARTNER = 'other_partner'
OTHER_ADMIN_PARTNER = 'other_admin_partner'
NO_PARTNER = 'NO_PARTNER'
EMPTY_PARTNER = ''

def json_response
  json_response = JSON.parse last_response.body, symbolize_names: true

  Json.lock_values json_response
end

def assert_response_status status
  last_response.status.must_equal status
end

def assert_response_message message
  json_response[:message].must_equal message
end

def assert_response_status_must_be_ok
  assert_response_status 200
end

def assert_response_status_must_be_created
  assert_response_status 201
  assert_response_header_location_must_be_set
end

def assert_response_status_must_be_bad_request
  assert_response_status 400
end

def assert_response_status_must_be_not_found
  assert_response_status 404
end

def assert_response_status_must_be_unprocessable_entity
  assert_response_status 422
end

def assert_response_message_must_be_bad_request
  assert_response_status_must_be_bad_request

  assert_response_message 'Bad Request'
end

def assert_response_message_must_be_validation_failed
  assert_response_status_must_be_unprocessable_entity

  assert_response_message 'Validation Failed'
end

def assert_response_message_must_be_not_found
  assert_response_status_must_be_not_found

  assert_response_message 'Not Found'
end

def assert_validation_failed_errors_must_include field, code
  error = { field: field, code: code }

  json_response[:errors].must_include error
end

def assert_response_header_location_must_be_set
  last_response.header['Location'].wont_equal nil
end

def partner_authenticated
  @current_user = create :user
  @current_partner = @current_user.partner

  authenticate!
end

def admin_authenticated
  @current_user = create :admin
  authenticate!

  partner_exists NON_ADMIN_PARTNER
end

def partner_does_not_exist name
  partner = Partner.find_by(name: name)
  partner.delete if partner
end

def partner_exists name, admin: false
  partner_does_not_exist name

  @current_partner = create :complete_partner, name: name, admin: admin
end

def other_partner_exists
  partner_exists OTHER_PARTNER
end

def other_partner_does_not_exist
  partner_does_not_exist OTHER_PARTNER
end

def other_admin_partner_exists
  partner_exists OTHER_ADMIN_PARTNER, admin: true
end

def authenticate!
  authorization = @current_user.authorizations.create

  header  'Authorization',
          ActionController::HttpAuthentication::Token.encode_credentials(authorization.token)
end

OBJECT_ACTIVITY_SCENARIOS = {
  'set client hold'                   => { type: :update, property: :client_hold, old_value: false, value: true },
  'set client delete prohibited'      => { type: :update, property: :client_delete_prohibited, old_value: false, value: true },
  'set client renew prohibited'       => { type: :update, property: :client_renew_prohibited, old_value: false, value: true },
  'set client transfer prohibited'    => { type: :update, property: :client_transfer_prohibited, old_value: false, value: true },
  'set client update prohibited'      => { type: :update, property: :client_update_prohibited, old_value: false, value: true },
  'unset client hold'                 => { type: :update, property: :client_hold, old_value: true, value: false },
  'unset client delete prohibited'    => { type: :update, property: :client_delete_prohibited, old_value: true, value: false },
  'unset client renew prohibited'     => { type: :update, property: :client_renew_prohibited, old_value: true, value: false },
  'unset client transfer prohibited'  => { type: :update, property: :client_transfer_prohibited, old_value: true, value: false },
  'unset client update prohibited'    => { type: :update, property: :client_update_prohibited, old_value: true, value: false },
}


def latest_activity
  saved_domain.domain_activities.last
end

def assert_latest_object_activity(scenario:)
  activity = OBJECT_ACTIVITY_SCENARIOS[scenario]

  latest_activity.must_be_kind_of ObjectActivity::Update if activity[:type] == :update

  latest_activity.property_changed.to_sym.must_equal activity[:property]
  latest_activity.old_value.must_equal activity[:old_value].to_s
  latest_activity.value.must_equal activity[:value].to_s
end
