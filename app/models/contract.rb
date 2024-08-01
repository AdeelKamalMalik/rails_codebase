require 'csv'

class Contract < ApplicationRecord
  include PublicIdGenerator
  self.public_id_prefix = "con"

  DEFAULT_UPLOAD_LIMIT = 2

  belongs_to :user, foreign_key: "user_id"
  has_many :contract_files, dependent: :destroy
  has_many :products, -> { order(created_at: :desc) }, dependent: :destroy
  belongs_to :vendor, optional: true

  accepts_nested_attributes_for :contract_files, reject_if: :all_blank
  accepts_nested_attributes_for :products, reject_if: :all_blank, allow_destroy: true

  scope :ending_in, -> (days = 90) { where("end_date >= ? AND end_date <= ?", Date.today, Date.today + days.days) }
  scope :not_draft, -> { where.not(status: :draft) }

  enum status: { draft: 0, active: 1, expired: 2, archived: 3 }
  enum review_input: { needs_review: 0, reviewed: 1 }

  delegate :name, :public_id, to: :vendor, prefix: 'vendor', allow_nil: true

  # callbacks
  after_commit :update_vendor_cache_columns, unless: :draft?
  before_save :calculate_monthly_cost, unless: :draft?
  after_create :broadcast_created

  # Instance Methods
  %i[annual monthly total].each do |suffix|
    method_name = "#{suffix}_price_cents"
    define_method(method_name) do
      (send("#{suffix}_cost") || 0) * 100
    end
    monetize method_name.to_sym, with_model_currency: :currency_code
  end

  def ended?
    end_date&.past?
  end

  def ending_in?(days = 3)
    return false if indefinite? || ended?

    end_date <= Date.today + days
  end

  def indefinite?
    !end_date.present?
  end

  def send_expiry_email
    return if indefinite?

    UserMailer.contract_expiring(self).deliver
  end

  def to_param
    public_id
  end

  private

  def broadcast_created
    ContractChannel.broadcast_to(
      user, { action: 'created', data: { contract: { id:, public_id:, status:, vendor_public_id: } } }
    )
  end

  def calculate_monthly_cost
    self.monthly_cost = (annual_cost || 0) / 12
  end

  def update_vendor_cache_columns
    vendor.update_cache_columns
  end
end
