class AddDeviceTokensToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :device_tokens, :jsonb, default: '{}'
  end
end
