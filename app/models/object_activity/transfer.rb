class ObjectActivity::Transfer < ObjectActivity
  belongs_to :losing_partner, class_name: Partner

  validates :losing_partner, presence: true

  def as_json options = nil
    {
      id: self.id,
      type: 'transfer',
      activity_at: self.activity_at.iso8601,
      object: {
        id: self.product.domain.id,
        type: 'domain',
        name: self.product.domain.full_name
      },
      losing_partner: self.losing_partner.name
    }
  end
end