class AddLastViewedAtToContracts < ActiveRecord::Migration[7.1]
  def change
    add_column :contracts, :last_viewed_at, :datetime
  end
end
