class SyncCreateContactJob < ActiveJob::Base
  queue_as :sync_changes
  
  URL = "#{Rails.configuration.x.cocca_api_host}/contacts"

  def perform params
    HTTParty.post URL, body: params.to_json, headers: { 'Content-Type' => 'application/json', 'Accept' => 'application/json'}
  end
end
