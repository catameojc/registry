class OrderDetail::RenewDomain < OrderDetail
  validates :domain, presence: true
  validates :renewed_at, presence: true
  validates :period, presence: true

  def self.build params, partner
    order_detail = self.new
    order_detail.domain = params[:domain]
    order_detail.period = params[:period].to_i
    order_detail.renewed_at = params[:renewed_at].in_time_zone
    order_detail
  end

  def action
    'domain_renew'
  end

  def complete!
    domain = self.order.partner.renew_domain domain_name: self.domain, period: self.period

    if domain.errors.empty?
      self.status = COMPLETE_ORDER_DETAIL

      self.order.partner.credits.create order: self.order,
                                        credits: self.price * -1,
                                        activity_type: 'use'
    else
      self.status = ERROR_ORDER_DETAIL
    end

    self.save

    self.complete?
  end

  def as_json options = nil
    {
      type: 'domain_renew',
      price: self.price.to_f,
      domain: self.domain,
      period: self.period.to_i,
      renewed_at: self.renewed_at.iso8601
    }
  end
end