class Vendor < ApplicationRecord
  include PublicIdGenerator
  self.public_id_prefix = "ven"

  # Associations

  belongs_to :user, optional: true
  has_many :contracts, dependent: :destroy
  has_one :recent_contract, -> { where.not(end_date: nil).not_draft.order(end_date: :desc) }, class_name: "Contract"

  # Scopes

  scope :ending_in, ->(days = 90) { where("end_date >= ? AND end_date <= ?", Date.today, Date.today + days.days) }

  enum status: {draft: 0, active: 1, expired: 2, archived: 3}
  enum review_status: {needs_review: 0, reviewed: 1}

  # Class methods

  # Instance methods

  def domain
    return unless vendor_url.present?

    host = URI.parse(vendor_url).host || vendor_url
    host.gsub("www.", "")
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

  def to_param
    public_id
  end

  def update_cache_columns
    return unless recent_contract.present?

    columns = {annual_cost: contracts.sum(:annual_cost), end_date: recent_contract.end_date,
               monthly_cost: contracts.sum(:monthly_cost), review_status: recent_contract.review_input}
    # columns[:status] = recent_contract.status unless archived?
    update(columns)
  end
end
