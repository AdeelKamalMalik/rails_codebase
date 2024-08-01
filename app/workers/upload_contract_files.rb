require 'json'

class UploadContractFiles
  include Sidekiq::Job

  def perform(contract_id, signed_ids)
    signed_ids = Array(signed_ids)
    return unless (contract = Contract.find_by(id: contract_id)).present? && signed_ids.present?

    signed_ids.each do |signed_id|
      next unless blob(signed_id).present?

      contract.contract_files.create(file: blob(signed_id), status: :analyzing, type: 'Msa')
    end
  end

  private

  def blob(signed_id)
    if signed_id.eql?('sample')
      ActiveStorage::Blob.create_and_upload!(io: File.open(Rails.root.join('public', 'contract.doc')),
        filename: 'contract.doc')
    else
      ActiveStorage::Blob.unattached.find_signed(signed_id)
    end
  end
end
