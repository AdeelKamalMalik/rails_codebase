class VendorsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_vendor, only: [:archive, :show, :unarchive, :update]

  def archive
    if @vendor.update(status: :archived)
      flash[:notice] = 'Vendor archived!'
    end
    redirect_to root_path
  end

  def download_csv
    query = { user_id: current_user.id }
    query[:vendor_id] = current_user.vendors.find_by(public_id: params[:public_id]) if params[:public_id].present?

    respond_to do |format|
      format.csv do
        service = DownloadContractsCsvService.new(Contract.where(query))
        xlsx_data = service.call
        send_data xlsx_data, filename: "contracts-#{DateTime.now.strftime("%d%m%Y%H%M")}.xlsx", type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
      end
    end
  end

  def index
    @vendors = current_user.vendors
    @vendors = @vendors.where('name ILIKE ?', "%#{params[:q]}%") if params[:q]
    respond_to do |format|
      format.json { render json: @vendors, status: :ok }
    end
  end

  def show
    @contracts = @vendor.contracts.not_draft
  end

  def unarchive
    if @vendor.update(status: :active)
      flash[:notice] = 'Vendor unarchived!'
    end
    redirect_to root_path
  end

  def update
    respond_to do |format|
      @vendor.update(vendor_params)
      format.html
      format.json { render json: { vendor: @vendor }, status: !@vendor.errors.present? ? :ok : :bad_request }
    end
  end

  private

  def vendor_params
    params.require(:vendor).permit(:name, :status).merge({ user_id: current_user.id })
  end

  def find_vendor
    @vendor = current_user.vendors.find_by!(public_id: params[:public_id])
  end
end
