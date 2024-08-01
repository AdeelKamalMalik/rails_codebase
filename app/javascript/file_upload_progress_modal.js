addEventListeners = () => {
  $('.contract-file-status.review_needed').on('click', (e) => {
    window.location = $(e.currentTarget).attr('href')
  })
}
addOrUpdateRow = (file, mode) => {
  if($(`#files-container [dynamic-id='${file.blob_id}']`).length == 0){
    if(mode == 'prepend')
      $('#file-upload-progress-modal #files-container').prepend(setupRow(file))
    else if(mode == 'append')
      $('#file-upload-progress-modal #files-container').append(setupRow(file))
  } else {
    $(`#files-container [dynamic-id='${file.blob_id}']`).find('.contract-file-status').remove()
    $(`#files-container [dynamic-id='${file.blob_id}'] .status-and-type`).prepend(statusBadge(file))
    $(`#files-container [dynamic-id='${file.blob_id}']`).find('.document-type').text(file['type'].toUpperCase())
  }
}

setupRow = (file) => {
  template = rowTemplate()
  template.attr('dynamic-id', file['blob_id'])
  template.attr('id', file['id'])
  template.find('.contract-file-status').remove()
  template.find('.status-and-type').prepend(statusBadge(file))
  template.find('.document-type').text(file['type'].toUpperCase())
  template.find('.filename').text(file['name'])
  template.find('.filename').attr('data-tooltip-content-value', `${file['name']}`)
  return template
}

showProgressModal = () => {
  Alpine.store('fileUploadProgressModal').showUploadStatusModal()
}

statusBadge = (file) => {
  if (file.status == 'analyzing' || file.status == 'on_hold' || file.status == 'uploading') {
    badge = rowTemplate().find(`.contract-file-status.${file.status}`)
    badge.attr('href', file['details'])
    return badge
  }
}

syncProgressModal = (data, mode="prepend", clearPreviosState = false) => {
  if(clearPreviosState) $('#file-upload-progress-modal #files-container').empty()
  data.blobs.forEach((file) => {
    addOrUpdateRow(file, mode)
  })
  addEventListeners()
}

rowTemplate = () => {
  return $('#contract-file-row-template #contract-file-template').clone()
}
