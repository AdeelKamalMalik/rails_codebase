module ContractFilesHelper
  def document_type_options
    ContractFile::DOCUMENT_TYPES.collect do |label, _|
      [t("activerecord.attributes.contract_file/document_type.#{label.downcase}"), label]
    end
  end

  def file_status_badge(file, id: "", classes: "")
    "
      <div id='#{id}' class='flex gap-1.5 text-xs font-medium whitespace-nowrap py-[5px] px-1.5 border rounded-lg contract-file-status #{classes} #{status_badge_classes(file.status)}' href='#{vendor_path(file.contract.vendor, {tab: file.contract.public_id}) if file.review_needed? && file.contract.vendor.present?}'>
        #{file.status&.titleize}
        #{checked_svg_filled if file.reviewed?}
        #{loader_svg if file.analyzing?}
        #{loader_svg(classes: "text-gray-700") if file.uploading?}
      </div>
    ".html_safe
  end
end
