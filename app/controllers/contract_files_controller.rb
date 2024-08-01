class ContractFilesController < ApplicationController
  before_action :authenticate_user!
  before_action :find_file, only: [:update, :move, :destroy, :update_document_type]

  def index
    @files = current_user.contract_files.order(updated_at: :desc)

    respond_to do |format|
      format.html # Fallback for normal requests
      format.json do
        render json: {
          files: @files.map do |file|
            vendor = file.contract.vendor
            file.slice(:id, :status).merge(
              {
                details: vendor.present? ? vendor_path(vendor, { tab: file.contract.public_id }) : '',
                blob_id: file.file.signed_id, name: file.file.filename,
                type: %w[uploading analyzing].include?(file.status) ? '' : file.type
              }
            )
          end
        }, status: :ok
      end
    end
  end

  def update
    @contract_file.update(contract_file_params)
    respond_to do |format|
      format.json {
        render json: { file: @contract_file, errors: @contract_file.errors.full_messages },
          status: @contract_file.errors.present? ? :bad_request : :ok
      }
    end
  end

  def update_document_type
    new_type = params[:contract_file][:new_type].to_s.titleize
    @contract_file.update(type: new_type)
    @contract_file = ContractFile.find_by(id: params[:id], type: new_type)

    respond_to do |format|
      format.json do
        render json: { file: { type: @contract_file.type }, errors: @contract_file.errors.full_messages },
          status: @contract_file.errors.present? ? :bad_request : :ok
      end
    end
  end

  def destroy
    respond_to do |format|
      if @contract_file.destroy
        format.json { head :no_content }
      else
        format.json { render json: { errors: @contract_file.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end


  def move
    permitted = params.require(:contract_file).permit(:contract_id)
    @contract_file.update(contract_id: permitted[:contract_id])

    respond_to do |format|
      format.json {
        render json: { file: @contract_file, errors: @contract_file.errors.full_messages },
          status: @contract_file.errors.present? ? :unprocessable_entity : :ok
      }
    end
  end

  private

  def contract_file_params
    params.require(:contract_file).permit(:document_type, :status)
  end

  def find_file
    @contract_file = ContractFile.find_by!(id: params[:id])
  end
end
