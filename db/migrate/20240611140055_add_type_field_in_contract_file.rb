class AddTypeFieldInContractFile < ActiveRecord::Migration[7.1]
  def change
    add_column :contracts, :vendor_id, :integer

    change_table :contract_files do |t|
      t.string :type
      t.string :order_number
      t.boolean :purchase_order_required
      t.string :purchase_order_number
      t.string :vendor_name
      t.string :payment_terms
      t.string :billing_frequency
      t.string :currency
      t.boolean :marketing_clause
      t.string :marketing_clause_text
      t.boolean :auto_renewal_clause
      t.string :auto_renewal_clause_text
      t.string :renewal_notice_period
      t.boolean :termination_clause
      t.string :termination_clause_text
      t.datetime :start_date
      t.datetime :end_date
      t.datetime :effective_date
      t.datetime :signature_date
      t.datetime :expiry_date
      t.string :counterparty_contact_name
      t.string :counterparty_contact_email
      t.string :client_contact_name
      t.string :client_contact_email
    end

    ContractFile.update_all(type: "Msa")
  end
end
