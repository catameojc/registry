class OrderDetail::ReplenishCredits < OrderDetail
  validates :remarks, presence: true

  def self.build params, partner
    order_detail = self.new
    order_detail.price = params[:credits].money
    order_detail.credits = params[:credits].money
    order_detail.remarks = params[:remarks]

    order_detail
  end

  def self.execute partner:, credits:, remarks:, at: Time.current
    saved_partner = Partner.find_by! name: partner
    price = credits.money

    o = Order.new partner:  saved_partner,
                  total_price:  price,
                  ordered_at: at

    od = self.new price: price, credits: price, remarks: remarks

    o.order_details << od
    o.save!

    o.complete!
  end

  def action
    'credits'
  end

  def complete!
    self.status = COMPLETE_ORDER_DETAIL

    self.order.partner.credits.create order: self.order,
                                      amount: self.price,
                                      activity_type: 'topup'

    self.save
  end

  def as_json options = nil
    {
      type: 'credits',
      object: self.product.as_json,
      price: price.to_f,
    }
  end
end
