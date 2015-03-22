class OrderDetail::RegisterDomain < OrderDetail
  validates :domain, presence: true
  validates :period, presence: true
  validates :registrant_handle, presence: true
  validates :registered_at, presence: true

  def self.build params, partner
    new params
  end

  def action
    'domain_create'
  end

  def complete!
    new_domain = self.order.partner.register_domain self.domain,
                                                    period: self.period,
                                                    registrant_handle: self.registrant_handle,
                                                    registered_at: self.registered_at

    if new_domain.errors.empty?
      self.status = COMPLETE_ORDER_DETAIL

      self.order.partner.credits.create order: self.order,
                                        credits: self.price * -1,
                                        activity_type: 'use'
    else
      self.status = ERROR_ORDER_DETAIL
    end

    self.save

    new_domain.errors.each do |field, code|
      errors.add(field, code)
    end

    self.complete?
  end

  def as_json options = nil
    {
      type: 'domain_create',
      price: price.to_f,
      domain: domain,
      period: (period.to_i unless period.nil?),
      registrant_handle: registrant_handle,
      registered_at: self.registered_at.iso8601
    }
  end
end