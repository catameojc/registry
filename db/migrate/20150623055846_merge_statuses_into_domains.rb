class MergeStatusesIntoDomains < ActiveRecord::Migration
  def change
    add_column :domains, :ok,                         :boolean, null: false, default: false
    add_column :domains, :inactive,                   :boolean, null: false, default: true
    add_column :domains, :client_hold,                :boolean, null: false, default: false
    add_column :domains, :client_delete_prohibited,   :boolean, null: false, default: false
    add_column :domains, :client_renew_prohibited,    :boolean, null: false, default: false
    add_column :domains, :client_transfer_prohibited, :boolean, null: false, default: false
    add_column :domains, :client_update_prohibited,   :boolean, null: false, default: false

    Domain.all.each do |dom|
      statuses = [:ok, :inactive, :client_hold, :client_delete_prohibited, 
        :client_renew_prohibited, :client_transfer_prohibited, 
        :client_update_prohibited]
      statuses.each do |status|
        dom.send("#{status}=", dom.product.object_status.send(status))
      end

      dom.save
    end
  end
end
