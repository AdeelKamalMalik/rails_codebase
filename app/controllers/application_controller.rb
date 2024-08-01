class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  include ActiveStorage::SetCurrent
  include BundleAssets
  include SetCurrentRequestDetails
  include SetLocale
  include Jumpstart::Controller
  include Accounts::SubscriptionStatus
  include Users::NavbarNotifications
  include Users::Sudo
  include Users::TimeZone
  include Pagy::Backend
  include CurrentHelper
  include Sortable
  include DeviceFormat
  include Users::AgreementUpdates
  include Authorization

  before_action :configure_permitted_parameters, if: :devise_controller?

  impersonates :user

  protected

  def after_sign_in_path_for(resource_or_scope)
    if !resource_or_scope.onboarding?
      privacy_user_onboarding_path
    elsif !resource_or_scope.two_factor_enabled?
      setup_user_two_factor_path
    else
      stored_location_for(resource_or_scope) || super
    end
  end

  # Helper method for verifying authentication in a before_action, but redirecting to sign up instead of login
  def authenticate_user_with_sign_up!
    unless user_signed_in?
      store_location_for(:user, request.fullpath)
      redirect_to new_user_registration_path, alert: t("create_an_account_first")
    end
  end

  # To add extra fields to Devise registration, add the attribute names to `extra_keys`
  def configure_permitted_parameters
    extra_keys = [:avatar, :name, :time_zone, :preferred_language, :theme, :first_name, :last_name, :role, :how_heard_about_us]
    signup_keys = extra_keys + [:terms_of_service, :invite, owned_accounts_attributes: [:name, :alternative_name, :id, :website]]
    devise_parameter_sanitizer.permit(:sign_up, keys: signup_keys)
    devise_parameter_sanitizer.permit(:account_update, keys: signup_keys)
    devise_parameter_sanitizer.permit(:accept_invitation, keys: extra_keys)
  end

  def require_current_account_admin
    unless current_account_admin?
      redirect_to root_path, alert: t("must_be_an_admin")
    end
  end

  def sort_params
    params[:sort]&.split(',')&.map(&:strip)&.reduce({}) do |sort, condition|
      sort[condition.gsub('-', '').to_sym] = condition.starts_with?('-') ? :desc : :asc
      sort
    end
  end

  private

  def require_account
    redirect_to new_user_registration_path unless current_account
  end
end
