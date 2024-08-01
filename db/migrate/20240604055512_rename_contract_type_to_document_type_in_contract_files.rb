class RenameContractTypeToDocumentTypeInContractFiles < ActiveRecord::Migration[7.1]
  def change
    rename_column :contract_files, :contract_type, :document_type
  end
end
