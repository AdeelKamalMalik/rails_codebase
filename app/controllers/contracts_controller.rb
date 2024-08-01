class ContractsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_contract, only: %i[archive show unarchive upload_file update]
  before_action :products_count, only: [:update]
  before_action :find_vendor, only: [:create]

  def archive
    archived = @contract.update(status: :archived)
    flash[:notice] = 'Contract archived!' if archived
    redirect_to root_url
  end

  def create
    attributes = {
      user_id: current_user.id, name: 'slack', vendor_id: @vendor&.id
    }
    @contract = Contract.new(attributes)
    return unless @contract.save

    if current_user.contracts.count == 1 && @contract.draft?
      ContractChannel.broadcast_to(current_user, { action: 'first_contract' })
    end
    UploadContractFiles.perform_async(@contract.id, params[:signed_ids])
  end

  def show
    @contract&.products&.build unless @contract&.products&.exists?
  end

  def unarchive
    unarchived = @contract.update(status: :active)
    flash[:notice] = 'Contract unarchived!' if unarchived
    redirect_to root_url
  end

  def update
    respond_to do |format|
      @contract.update(contract_params)
      flash[:notice] = "Product added successfully" if @contract.products.count > @products_count
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("con-#{@contract.id}", partial: 'contracts/form', locals: { contract: @contract }),
          turbo_stream.update("products#{@contract.id}", partial: "contracts/products", locals: { contract: @contract.reload }),
          turbo_stream.replace("saving-contract", partial: "contracts/save_button"),
          turbo_stream.replace("summary-#{@contract.id}", partial: "contracts/summary", locals: { contract: @contract }),
          turbo_stream.replace_all(".contract-name#{@contract.id}", "<span class='contract-name#{@contract.id}'>#{@contract.name}</span>")
        ]
      end
      format.json { render json: { contract: @contract }, status: !@contract.errors.present? ? :ok : :bad_request }
    end
  end

  def upload_file
    UploadContractFiles.perform_async(@contract.id, params[:signed_ids])
  end

  def download_csv
    query = { user_id: current_user.id, status: Contract.statuses.except(:draft).keys }
    query[:public_id] = params[:public_id] if params[:public_id].present?

    respond_to do |format|
      format.csv do
        service = DownloadContractsCsvService.new(Contract.where(query))
        xlsx_data = service.call
        send_data xlsx_data, filename: "contracts-#{DateTime.now.strftime("%d%m%Y%H%M")}.xlsx", type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
      end
    end
  end

  def vendors
    if params[:q]
      @contracts = Contract.where('name ILIKE ?', "%#{params[:q]}%")
    else
      @contracts = Contract.all
    end

    render json: @contracts, status: :ok
  end

  def sample
    respond_to do |format|
      format.html  {
        send_file Rails.root.join('public', 'contract.doc'),
            filename: 'contract.doc', type: 'application/pdf'
      }
      format.json  {
        render json: {
          file_size: File.read(Rails.root.join('public', 'contract.doc')).size,
          file_url: "#{root_url}/contract.doc",
        }
      }
    end
  end

  private

  def contract_params
    params.require(:contract).permit(:name, :status, :start_date, :end_date, :order_number, :renewal_date, :vendor_id,
      :marketing_clause, :auto_renewal, :currency_code, :billing_interval, :payment_terms, :annual_cost, :total_cost,
      :purchase_order_required, :last_viewed_at, :review_input, products_attributes: %i[id name quantity notes unit start_date end_date sales_price
        sales_tax discount _destroy]).merge({ user_id: current_user.id })
  end

  def find_contract
    @contract = Contract.find_by!(public_id: params[:public_id])
  end

  def find_vendor
    @vendor = Vendor.find_by(public_id: params[:vendor_id])
  end

  def products_count
    @products_count = @contract.products&.count
  end
end
