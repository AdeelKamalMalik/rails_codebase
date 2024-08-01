class BlobsController < ApplicationController
  def destroy
    blob = ActiveStorage::Blob.unattached.find_signed(params[:signed_id])
    blob&.purge_later
  end
end
