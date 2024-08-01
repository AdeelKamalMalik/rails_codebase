class Users::TwoFactorController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_backup_codes
  before_action :ensure_otp_secret
  layout 'devise', except: [:update_setup, :update_m_setup]

  def show
    redirect_to edit_user_password_path
  end

  def backup_codes
    redirect_to root_path, alert: t(".already_sms") if current_user.sms_2fa_enabled?
  end

  def verify
    redirect_to root_path, alert: t(".already_sms") if current_user.sms_2fa_enabled?
  end

  def setup; end

  def update_m_setup
    redirect_to account_settings_path(tab: 2), alert: t(".already_app") if current_user.app_2fa_enabled?
  end

  def update_setup
    redirect_to account_settings_path(tab: 2), alert: t(".already_sms") if current_user.sms_2fa_enabled?
  end

  def create
    if current_user.verify_and_consume_otp!(params[:code])
      save_device_token if ActiveRecord::Type::Boolean.new.cast(params[:remember_me])
      current_user.enable_two_factor!
      redirect_to root_path, notice: t(".enabled")
    else
      redirect_url = if request.referer.include?('verify_code')
        request.referer
      else
        "#{request.referer}?verify_code=false"
      end

      redirect_to redirect_url
    end
  end

  def destroy
    current_user.disable_two_factor!
    redirect_to request.referer, status: :see_other, notice: t(".disabled")
  end

  def add_phone
    redirect_to root_path, alert: t(".already_sms") if current_user.phone_number
  end

  def verify_phone; end

  def send_verification_code
    if params[:phone_number].present? and params[:country_code].present?
      current_user.update(phone_number: params[:phone_number], country_code: params[:country_code])
    end

    to_phone = "#{current_user.country_code}#{current_user.phone_number}"
    begin
      response = TwilioService.start_verification(to_phone)
      status = :ok
      message = "Verification code has been sent to #{to_phone}"
    rescue Exception => e
      status = e.status_code
      message = e.message
    end
    render json: {
      message: message
    }, status: status
  end

  def check_verification_code
    to_phone = "#{current_user.country_code}#{current_user.phone_number}"
    begin
      response = TwilioService.check_verification(to_phone, params[:verification_code])
      if response.status == 'approved'
        current_user.update(phone_verified: true, otp_source: :sms)
        save_device_token if params[:remember_this_device]
        message = "#{to_phone} Verified"
        status = :ok
      else
        message = "Incorrect validation code"
        status = :unprocessable_entity
      end

    rescue Exception => e
      status = e.status_code
      message = e.message
    end

    render json: {
      message: message
    }, status: status
  end

  private

  def ensure_backup_codes
    current_user.generate_otp_backup_codes! unless current_user.otp_backup_codes?
  end

  def ensure_otp_secret
    current_user.set_otp_secret!
  end

  def save_device_token
    token = SecureRandom.alphanumeric(32)
    token_expires_at = Time.current + 30.days

    cookies.encrypted[:device_token] = {
      value: token,
      expires: token_expires_at,
      same_site: :strict,
      httponly: true,
      secure: Rails.env.production?
    }

    current_user.update(device_tokens: current_user.device_tokens.merge({ token => token_expires_at }))
  end
end
