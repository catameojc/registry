require 'test_helper'

describe OrderDetail::MigrateDomain do
  describe :as_json do
    subject { build(:migrate_domain_order_detail).as_json }

    specify { subject[:type].must_equal 'migrate_domain' }
    specify { subject[:price].must_equal 0.00 }
    specify { subject[:domain].must_equal 'domain.ph' }
    specify { subject[:registrant_handle].must_equal 'domains_r' }
    specify { subject[:registered_at].must_equal '2015-04-10T11:00:00Z' }
    specify { subject[:expires_at].must_equal '2017-04-10T11:00:00Z' }
  end

  describe :complete! do
    subject { create :migrate_domain_order_detail }

    before do
      create :contact, handle: subject.registrant_handle

      subject.complete!
    end

    let(:saved_domain) { Domain.named(subject.domain) }
    let(:latest_ledger_entry) { subject.order.partner.credits.last }

    context :when_successful do
      specify { subject.complete?.must_equal true }

      specify { saved_domain.full_name.must_equal subject.domain }
      specify { saved_domain.registered_at.must_equal subject.registered_at }
      specify { saved_domain.expires_at.must_equal subject.expires_at }

      specify { latest_ledger_entry.activity_type.must_equal 'use' }
      specify { latest_ledger_entry.credits.must_equal 0.00 }
    end
  end
end