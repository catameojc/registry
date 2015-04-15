class ObjectActivity < ActiveRecord::Base
  belongs_to :partner
  belongs_to :product

  validates :partner,     presence: true
  validates :product,     presence: true
  validates :activity_at, presence: true

  def self.latest
    self.all.order(id: :desc).limit(1000)
  end
end