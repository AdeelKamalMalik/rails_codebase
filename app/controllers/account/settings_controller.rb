class Account::SettingsController < ApplicationController
  before_action :authenticate_user!

  def show
    @payment_processor = current_account.payment_processor
    @subscriptions = current_account.subscriptions.active.or(current_account.subscriptions.past_due).or(current_account.subscriptions.unpaid).order(created_at: :asc).includes([:customer])
  end

  def update
    if current_user.update_with_password(password_params)
      bypass_sign_in current_user
      redirect_to account_settings_path, notice: t(".updated")
    else
      render :show, status: :unprocessable_entity, locals: {open_modal: true}
    end
  end

  def destroy
    current_user.discard
    redirect_to new_user_session_path
  end

  private

  def password_params
    params.require(:user).permit(:current_password, :password, :password_confirmation)
  end
end
