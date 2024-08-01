class AddRoleHowHeardToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :role, :string
    add_column :users, :how_heard_about_us, :string
    add_column :users, :onboarding, :boolean, default: false
  end
end
