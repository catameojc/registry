require 'test_helper'

describe DomainInfoSerializer do
  let(:current_partner) { create :partner }
  let(:other_partner)   { create :other_partner }
  let(:admin_partner)   { create :admin_partner }

  subject {
    d = DomainInfoSerializer.new(domain)
    d.class.module_eval {
      attr_accessor :current_user
    }
    d.current_user = current_partner
    d.serializable_hash
  }

  context :when_contact_registrant_only do
    let(:domain) { create :domain }

    subject {
      d = DomainInfoSerializer.new(domain)
      d.class.module_eval {
        attr_accessor :current_user
      }
      current_partner.name = domain.partner.name
      d.current_user = current_partner
      d.serializable_hash
    }

    before do
      create :domain_host, product: domain.product, name: 'ns3.domains.ph'
      create :domain_host, product: domain.product, name: 'ns4.domains.ph'
    end

    specify { subject[:activities].wont_be_empty }
    specify { subject[:hosts].wont_be_empty }

    specify { subject.has_key?(:admin_contact).must_equal true }
    specify { subject.has_key?(:billing_contact).must_equal true }
    specify { subject.has_key?(:tech_contact).must_equal true }

    specify { subject[:admin_contact].must_be_nil }
    specify { subject[:billing_contact].must_be_nil }
    specify { subject[:tech_contact].must_be_nil }
  end

  context :when_all_contacts do
    let(:domain) { create :complete_domain }

    specify { subject[:admin_contact].wont_be_nil }
    specify { subject[:billing_contact].wont_be_nil }
    specify { subject[:tech_contact].wont_be_nil }
  end

  context :when_admin do
    let(:domain) { create :domain }

    subject {
      d = DomainInfoSerializer.new(domain)
      d.class.module_eval {
        attr_accessor :current_user
      }
      d.current_user = admin_partner
      d.serializable_hash
    }

    specify { subject[:activities].wont_be_empty }
  end

  context :when_other_partner do
    let(:domain) { create :domain }

    subject {
      d = DomainInfoSerializer.new(domain)
      d.class.module_eval {
        attr_accessor :current_user
      }
      d.current_user = other_partner
      d.serializable_hash
    }

    specify { subject[:activities].must_be_empty }
  end
end
