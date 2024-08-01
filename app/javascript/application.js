/* eslint no-console:0 */

import "@hotwired/turbo-rails"
require("@rails/activestorage").start()
require("local-time").start()

import "./channels"
import "./controllers"
import './file_upload_progress_modal'
import "./src/**/*"
import Alpine from 'alpinejs'
window.Alpine = Alpine
document.addEventListener('alpine:init', () => {
  Alpine.store('fileUploadProgressModal', {
    expanded: true, hidden: {'true': true, 'false': false}[window.localStorage.fileUploadProgressModalHidden],
    hideUploadStatusModal() {
      window.localStorage.fileUploadProgressModalHidden = true
      this.hidden = true
    },
    showUploadStatusModal() {
      window.localStorage.fileUploadProgressModalHidden = false
      this.hidden = false
    }
  })
})
Alpine.start()
document.addEventListener("turbo:frame-render", function (e) {
  $('.contract-file-status.review_needed').on('click', (e) => {
    window.location = $(e.currentTarget).attr('href')
  })
  if (e.target.id == 'file_upload_progress_modal_frame') {
    const storage = window.localStorage
    docs = JSON.parse(storage.getItem('uploadingDocs')) || []
    docs = docs.filter((doc) => {
      return $(`#files-container [dynamic-id='${doc.blob_id}']`).length == 0
    })
    storage.setItem('uploadingDocs', JSON.stringify(docs))
    modalHidden = {'true': true, 'false': false}[window.localStorage.fileUploadProgressModalHidden]
    if(docs.length > 0 && !modalHidden) syncProgressModal({ blobs: docs})
  }
})
