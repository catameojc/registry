require 'test_helper'

describe Product do
  subject { create :product }

  describe :associations do
    before do
      contact = create :contact

      create :domain,           product: subject, registrant: contact
      create :order_detail,     product: subject
      create :object_activity,  product: subject, type: ObjectActivity::Create
      create :deleted_domain,   product: subject, registrant: contact
    end

    specify { subject.order_details.wont_be_empty }
    specify { subject.domain.wont_be_nil }
    specify { subject.object_activities.wont_be_empty }
    specify { subject.deleted_domain.wont_be_nil }
  end

  describe :as_json do
    context :when_domain_product do
      subject { create :domain_product }

      let(:expected_json) {
        {
          id:   subject.domain.id,
          type: 'domain',
          name: subject.domain.name
        }
      }

      specify { subject.as_json.must_equal expected_json }
    end

    context :when_deleted_domain_product do
      subject { create :deleted_domain_product }

      let(:expected_json) {
        {
          id:   subject.deleted_domain.id,
          type: 'deleted_domain',
          name: subject.deleted_domain.name
        }
      }

      specify { subject.as_json.must_equal expected_json }
    end
  end
end
