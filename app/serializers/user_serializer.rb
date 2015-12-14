class UserSerializer < ActiveModel::Serializer
  attributes :id, :username, :token, :partner_id, :partner_name, :credits, :transactions_allowed, :admin, :staff, :email

  def partner_id
    object.id
  end

  def partner_name
    object.partner.name
  end

  def credits
    object.partner.current_balance.to_f
  end

  def transactions_allowed
    true
  end
end
