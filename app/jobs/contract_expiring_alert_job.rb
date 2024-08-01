class ContractExpiringAlertJob < ActiveJob::Base
  # Set the Queue as Default
  queue_as :default

  def perform
    Contract.joins(user: :alerts).where("alerts.enabled = true AND contracts.end_date IS NOT NULL AND
      alerts.expiring_in = EXTRACT(DAY FROM (contracts.end_date::timestamp - CURRENT_DATE::timestamp))"
    ).find_each do |contract|
      contract.send_expiry_email
    end
  end
end
