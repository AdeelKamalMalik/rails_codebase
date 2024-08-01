class User < ApplicationRecord
  include User::Accounts
  include User::Agreements
  include User::Authenticatable
  include User::Mentions
  include User::Searchable
  include User::Theme
  include Discard::Model

  has_many :api_tokens, dependent: :destroy
  has_many :connected_accounts, as: :owner, dependent: :destroy
  has_many :contracts
  has_many :notifications, as: :recipient, dependent: :destroy
  has_many :notification_tokens, dependent: :destroy
  has_many :vendors, dependent: :destroy

  has_noticed_notifications
  has_one_attached :avatar
  has_person_name
  has_many :alerts, dependent: :destroy

  # Associations :through
  has_many :contract_files, through: :contracts


  validates :avatar, resizable_image: true
  before_save :set_role_on_signup
  before_save :set_default_theme
  # Name is optional in our case
  # validates :name, presence: true

  serialize :device_tokens, coder: JsonbSerializers

  def business_plan?
    subscribed_plan&.name&.downcase == "business"
  end

  def contract_limit_reached?
    contracts_upload_limit != -99 && contracts_count >= contracts_upload_limit
  end

  def contracts_count
    contracts.present? ? contracts&.not_draft&.count : 0
  end

  def contracts_upload_limit
    return Contract::DEFAULT_UPLOAD_LIMIT if without_any_subscription?
    return -99 if enterprise_plan?

    subscribed_plan&.contracts_limit
  end

  def enterprise_plan?
    subscribed_plan&.name&.downcase == "enterprise"
  end

  def other_plan?
    !business_plan? && !enterprise_plan?
  end

  def subscribed_plan
    accounts&.first&.subscriptions&.last&.plan
  end

  def without_any_subscription?
    !subscribed_plan.present?
  end

  private

  def set_default_theme
    self.update(preferences: {'theme'=>'light'}) if self.new_record? && theme.nil?
  end

  def set_role_on_signup
    self.update(role: 'Admin') if self.new_record? && role.nil?
  end
end
