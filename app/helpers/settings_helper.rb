module SettingsHelper
  def app_2fa_enable_text
    current_user.app_2fa_enabled? ? 'Update' : 'Enable'
  end

  def sms_2fa_enable_text
    return 'Enable' unless current_user.sms_2fa_enabled?
    if current_user.phone_number.present?
      current_user.phone_verified? ? 'Update' : 'Verify phone number'
    end
  end
end
