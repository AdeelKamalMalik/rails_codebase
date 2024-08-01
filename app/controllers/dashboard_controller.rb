class DashboardController < ApplicationController
  def show
    redirect_to privacy_user_onboarding_path unless current_user.onboarding? || session[:onboarding_skipped]
    @effective_contracts = current_user.contracts.joins(:vendor).where.not(contracts: {status: :draft})
    @vendors = current_user.vendors.where(id: @effective_contracts.pluck(:vendor_id))
    @vendors = @vendors.where(query)
    @vendors = @vendors.ending_in(params[:expiring_in].to_i) if params[:expiring_in].present?
    @vendors = @vendors.order(sort_params.present? ? sort_params : {name: :asc})
    @vendors = @vendors.page(params[:page])&.per(10)
  end

  private

  def query
    q = {}
    q[:status] = params[:status] if params[:status] != "all" && Vendor.statuses.keys.include?(params[:status])
    q[:status] ||= "active" # Default to 'active' if status is not specified or invalid
    q.delete(:status) if params[:status] == "all"

    q[:review_status] = params[:reviewed] if Vendor.review_statuses.keys.include?(params[:reviewed])
    q
  end
end
