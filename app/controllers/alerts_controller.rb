class AlertsController < ApplicationController
  before_action :authenticate_user!

  def create
    @alert = current_user.alerts.find_by(expiring_in: params.dig(:alert, :expiring_in))

    if @alert
      @alert.update(alert_params)
    else
      @alert = Alert.new(alert_params)
      @alert.save
    end

    render json: {}, status: :ok
  rescue Exception => e
    render json: {}, status: :unprocessable_entity
  end

  private

  def alert_params
    params
      .require(:alert)
      .permit(:expiring_in, :enabled).merge({user_id: current_user.id})
  end
end
