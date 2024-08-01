class NewContractNotification < ApplicationNotification
  deliver_by :action_cable, format: :to_websocket, channel: "NotificationChannel"

  param :account
  param :contract_file

  def to_websocket
    {
      account_id: record.account_id,
      html: ApplicationController.render(partial: "notifications/notification", locals: {notification: record})
    }
  end

  def message
    "
      <b>#{t "notifications.contract_ready_for_review", filename:, contract: contract.name, vendor: vendor&.name}</b><br>
      <span class='text-gray-500'>#{t "notifications.click_to_review"}<span>
    ".html_safe
  end

  def url
    vendor_path(contract.vendor, {tab: contract.public_id})
  end

  def contract
    contract_file.contract
  end

  def contract_file
    params[:contract_file]
  end

  def filename
    contract_file.file&.filename
  end

  def vendor
    contract.vendor
  end
end
