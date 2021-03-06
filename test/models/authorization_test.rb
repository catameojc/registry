require 'test_helper'

describe Authorization do
  let(:current_user) { create :user }

  describe :generate_token do
    subject { Authorization.create(user: current_user, partner: current_user.partner) }

    specify { subject.token.wont_be_nil }
  end

  describe :update_timestamp do
    subject { Authorization.create(user: current_user, partner: current_user.partner) }

    specify { Authorization.find_by(token: subject.token).updated_at.wont_equal subject.updated_at }
  end
end
