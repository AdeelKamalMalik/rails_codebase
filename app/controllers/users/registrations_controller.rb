class Users::RegistrationsController < Devise::RegistrationsController
  invisible_captcha only: :create
  layout 'application', only: [:edit]

  def edit
    redirect_to account_settings_path(tab: 1)
  end

  protected

  def build_resource(hash = {})
    self.resource = resource_class.new_with_session(hash, session)

    # Jumpstart: Skip email confirmation on registration.
    #   Require confirmation when user changes their email only

    # Update: user should verify their email after signup
    # resource.skip_confirmation!

    # Registering to accept an invitation should display the invitation on sign up
    if params[:invite] && (invite = AccountInvitation.find_by(token: params[:invite]))
      @account_invitation = invite
      resource.skip_default_account = true

    # Build and display account fields in registration form if needed
    elsif Jumpstart.config.register_with_account?
      account = resource.owned_accounts.first || resource.owned_accounts.new
      account.account_users.new(user: resource, admin: true)
    end
  end

  def update_resource(resource, params)
    # Jumpstart: Allow user to edit their profile without password
    resource.update(onboarding: true) if onboarding_request
    resource.update_without_password(params)
  end

  def after_inactive_sign_up_path_for(resource)
    verify_email_path
  end

  def after_update_path_for(resource)
    if onboarding_request
      how_it_works_user_onboarding_path
    else
      request.referer
    end
  end

  def onboarding_request
    request.referer.include?('profile_information')
  end

  def sign_up(resource_name, resource)
    sign_in(resource_name, resource)

    # If user registered through an invitation, automatically accept it after signing in
    if @account_invitation
      @account_invitation.accept!(current_user)

      # Clear redirect to account invitation since it's already been accepted
      stored_location_for(:user)
    end
  end
end
