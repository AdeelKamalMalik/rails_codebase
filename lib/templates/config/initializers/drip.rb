# Drip API Client
# http://localhost:3000/jumpstart/docs/integrations
#
# Example usage:
# Jumpstart::Clients.drip.create_or_update_subscriber(email, options={})

client = Drip::Client.new { |c|
  c.api_key = ENV["DRIP_API_KEY"]
  c.account_id = ENV["DRIP_ACCOUNT_ID"]
}

Jumpstart::Clients.drip = client
