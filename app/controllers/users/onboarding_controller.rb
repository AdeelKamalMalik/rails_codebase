class Users::OnboardingController < ApplicationController
  before_action :authenticate_user!
  layout "devise"

  def do_it_later
    session[:onboarding_skipped] = true
    redirect_to root_path
  end
end
