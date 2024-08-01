class Users::SessionsController < Devise::SessionsController
  include Devise::Controllers::Rememberable

  # We need to intercept the Sessions#create action for processing OTP
  prepend_before_action :authenticate_with_two_factor, only: [:create]

  def authenticate_with_two_factor
    if sign_in_params[:email]
      self.resource = resource_class.find_by(email: sign_in_params[:email])

      # Any new login attempt should reset 2FA user
      clear_otp_user_from_session

      # Intercept Devise if 2FA required. Otherwise let Devise handle non-2FA auth
      unless skip_two_factor?
        authenticate_and_start_two_factor if resource&.two_factor_enabled?
      end
    elsif session[:otp_user_id]
      if session[:otp_source] == resource_class.otp_sources[:app]
        authenticate_otp_attempt
      else
        authenticate_otp_attempt_sms
      end
    end
  end

  def authenticate_and_start_two_factor
    if resource.valid_password?(sign_in_params[:password])
      session[:remember_me] = Devise::TRUE_VALUES.include?(sign_in_params[:remember_me])
      session[:otp_user_id] = resource.id
      session[:otp_source] = resource.otp_source_preference
      flash.now[:notice] = "Verification code sent to your number." if resource.sms_2fa_enabled?
      render :otp, status: :unprocessable_entity
    else
      # Let Devise handle invalid passwords
    end
  end

  def authenticate_otp_attempt
    self.resource = resource_class.find(session[:otp_user_id])

    if resource.verify_and_consume_otp!(params[:otp_attempt])
      clear_otp_user_from_session
      remember_me(resource) if session.delete(:remember_me)
      set_flash_message!(:notice, :signed_in)
      sign_in(resource, event: :authentication)
      respond_with resource, location: after_sign_in_path_for(resource)
    else
      flash.now[:alert] = t(".incorrect_verification_code")
      render :otp, status: :unprocessable_entity
    end
  end

  def authenticate_otp_attempt_sms
    self.resource = resource_class.find(session[:otp_user_id])

    phone_number = "#{resource.country_code}#{resource.phone_number}"
    # TwilioService.start_verification(phone_number)
    if resource.verify_and_consume_sms_otp!(phone_number, params[:otp_attempt])
      clear_otp_user_from_session
      remember_me(resource) if session.delete(:remember_me)
      set_flash_message!(:notice, :signed_in)
      sign_in(resource, event: :authentication)
      respond_with resource, location: after_sign_in_path_for(resource)
    else
      flash.now[:alert] = t(".incorrect_verification_code")
      render :otp, status: :unprocessable_entity
    end
  rescue Exception => e
    flash.now[:alert] = e.message
    render :otp, status: :unprocessable_entity
  end

  def clear_otp_user_from_session
    session.delete(:otp_user_id)
  end

  def otp
    self.resource = resource_class.find(session[:otp_user_id])
    to_phone = "#{resource&.country_code}#{resource&.phone_number}"

    begin
      TwilioService.start_verification(to_phone)
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

  private

  def skip_two_factor?
    # return true unless resource.otp_required_for_login?
    return false if !(cookie_token = cookies.encrypted[:device_token]).present?

    expiry = resource&.device_tokens&.dig(cookie_token)
    expiry ? DateTime.parse(expiry).future? : false
  end

  def verify_email
    redirect_to root_path if current_user
  end
end
