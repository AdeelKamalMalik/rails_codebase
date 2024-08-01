module User::Authenticatable
  extend ActiveSupport::Concern

  included do
    include TwoFactorAuthentication

    # Include default devise modules. Others available are:
    # :lockable, :timeoutable, and :trackable
    devise(*[:database_authenticatable, :registerable, :recoverable, :rememberable, :validatable, :confirmable, (:omniauthable if defined? OmniAuth)].compact)

    # Don't confirm email address on create, just when changed

    # Update: Send confirmation email on signup
    # before_create :skip_confirmation!

    # Protect admin flag from editing
    attr_readonly :admin

    def active_for_authentication?
      super && !discarded?
    end
  end
end
