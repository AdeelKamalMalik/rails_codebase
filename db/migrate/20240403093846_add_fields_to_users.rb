class AddFieldsToUsers < ActiveRecord::Migration[7.1]
  def change
    change_table :users do |t|
      t.integer :otp_source, default: 0
      t.integer :otp_added_timestamp
      t.string :phone_number
      t.string :country_code
      t.boolean :phone_verified, default: false
    end
  end
end
