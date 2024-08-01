import { Controller } from "@hotwired/stimulus";
import Dropzone from "dropzone";
import { DirectUpload } from "@rails/activestorage"
import { post, destroy } from "@rails/request.js"
import '../file_upload_progress_modal'

export default class extends Controller {
  static dropzone = null
  static targets = ['dropzone']
  static values = {
    signedIds: Array,
    redirectUrlOnSubmit: String
  }
  filesProcessed = 0

  connect() {
    const dropzoneConfig = {
      url: this.url,
      method: "post",
      clickable: ".dz-upload-prompt",
      autoQueue: false,
      paramName: 'file',
      acceptedFiles: ".pdf, .docx, .doc, .png, .jpg, .jpeg",
      maxFiles: this.element.dataset.maxFiles || 10,
      maxFilesize: this.element.dataset.maxFileSize || 10,
      headers: {
        "X-CSRF-Token": document.querySelector("meta[name=csrf-token]").content,
      },
      accept: (file, done) => {
        this.updateActionBtn()
        if(this.effectiveFileCount() > this.dropzone.options.maxFiles) {
          done("Max number of files reached!")
          return
        }
        const upload = new DirectUpload(file, this.url, this);
        upload.create((error, blob) => {
          if(error) return;

          let ids = this.signedIdsValue
          ids.push(blob.signed_id)
          this.signedIdsValue = ids
          file.previewElement.querySelector(".dz-remove").dataset.signedId = blob.signed_id
          done()
        })
        if(this.effectiveFileCount() == this.dropzone.options.maxFiles) {
          $('.dz-upload-prompt').removeClass('dz-clickable')
          this.disable()
          this.showError();
        }
      },

      error: function(file, errMsg) {
        if(errMsg.includes('File is too big')) {
          file.previewElement.querySelector(".dz-error-message").textContent = 'This file size is not supported';
        } else if (errMsg.includes('Upload canceled.')) {
          file.previewElement.querySelector(".dz-error-message").textContent = ""
        } else {
          file.previewElement.querySelector(".dz-error-message").textContent = errMsg
        }
      },
      removedfile: async (file) => {
        if(file.status == 'added') this.filesProcessed = Math.max(0, this.filesProcessed - 1)
        if(!event)
          return
        let singedId = event.currentTarget.dataset.signedId;
        const response = await destroy(`/blobs/${singedId}`, { dataType: 'json' })
        if(response.ok) {
          let ids = this.signedIdsValue
          let index = ids.indexOf(singedId)
          if (index !== -1) {
            ids.splice(index, 1)
            this.signedIdsValue = ids
          }
          if(this.dropzone.files.length == 0) {
            this.signedIdsValue = []
            document.getElementById('upload-files').classList.add('hidden')
          }
          if(this.dropzone.files.length < this.dropzone.options.maxFiles) {
            this.enable()
            this.hideError();
          }
          file.previewElement.remove()
        } else {
          console.log("something went wrong")
        }
      },
      previewsContainer: ".dropzone-previews",
      previewTemplate: `
        <div class="w-full border-b mt-10">
          <div class="dz-preview dz-file-preview pb-6">
            <div class="flex flex-row justify-between items-center w-full dz-details">
              <div class="flex items-center gap-4">
                <div class="dz-filename font-semibold text-gray-600"><span data-dz-name></span></div>
                <div class="dz-size text-gray-500 text-sm" data-dz-size></div>
                <div class="dz-error-message text-red-600 text-sm"><span data-dz-errormessage></span></div>
              </div>

              <button data-dz-remove class="dz-remove flex items-center gap-2 dz-remove-btn text-blue-700 font-semibold">
                <img src="${this.dropzoneTarget.dataset.removeImage}">
                <div>Remove</div>
              </button>
            </div>
          </div>
        </div>
      `
    }
    this.dropzone = new Dropzone(this.dropzoneTarget, dropzoneConfig);
  }

  get url() {
    return this.dropzoneTarget.dataset.directUploadUrl;
  }

  closeModal() {
    const id = "newContract"
    this.dropzone.removeAllFiles(true)
    $(this.dropzone.previewsContainer).empty()
    this.signedIdsValue = []
    document.getElementById(`${id}`).style.display = 'none'
  }

  directUploadWillStoreFileWithXHR(request) {
    request.upload.addEventListener("load", (event) => { this.filesProcessed += 1; this.updateActionBtn() })
    request.upload.addEventListener("loadstart", (event) => { this.updateActionBtn() })
  }

  disable() {
    this.dropzone.clickableElements.forEach((element) =>
      element.classList.remove("dz-clickable")
    );
    this.dropzone.removeEventListeners();
    this.disabled = true;
  }

  disconnect() {
    this.dropzone.destroy();
  }

  effectiveFileCount() {
    return this.dropzone.files.filter((f) => f.status == 'added').length
  }

  enable() {
    this.dropzone.enable()
  }

  hideError() {
    const errorMessage = document.getElementById('maxFilesError');
    errorMessage.classList.add('hidden');
  }

  goToDashboard () {
    this.signedIdsValue.forEach(async (signed_id) => {
      await destroy(`/blobs/${signed_id}`, { dataType: 'json' })
    })

    window.location.href = '/'
  }

  removeFiles() {
    this.signedIdsValue.forEach(async (signed_id) => {
      await destroy(`/blobs/${signed_id}`, { dataType: 'json' })
    })
    this.dropzone.removeAllFiles(true)
  }

  sampleContract () {
    fetch('/contracts/sample', {
      headers: {
        Accept: "application/json",
      },
    }).then(res => res.json())
    .then(response => {
      var mockFile = { name: 'contract.doc', size: response.file_size };
      this.dropzone.options.addedfile.call(this.dropzone, mockFile);
      this.dropzone.options.thumbnail.call(this.dropzone, mockFile);
      let ids = this.signedIdsValue
      ids.push('sample')
      this.signedIdsValue = ids
      document.getElementById('upload-files').classList.remove('hidden')
      this.filesProcessed += 1
    })
  }

  showError() {
    const errorMessage = document.getElementById('maxFilesError');
    errorMessage.classList.remove('hidden');
  }

  showProgress() {
    $('#file-upload-status').removeClass('hidden')
    $('#upload-file-label').text('Uploading files')
    $('#file-upload-status #successul-upload-file-count').text(0)
    $('#file-upload-status #failed-upload-file-count').text(0)
  }

  updateActionBtn () {
    const uploadBtn = document.getElementById('upload-files')
    var limit = Math.min(this.effectiveFileCount(), this.dropzone.options.maxFiles)
    if(uploadBtn) {
      if (this.filesProcessed < limit) {
        uploadBtn.disabled = true
        uploadBtn.innerHTML = `
          <svg aria-hidden="true" role="status" class="inline w-4 h-4 me-3 text-white animate-spin" viewBox="0 0 100 101" fill="none" xmlns="http://www.w3.org/2000/svg">
            <path d="M100 50.5908C100 78.2051 77.6142 100.591 50 100.591C22.3858 100.591 0 78.2051 0 50.5908C0 22.9766 22.3858 0.59082 50 0.59082C77.6142 0.59082 100 22.9766 100 50.5908ZM9.08144 50.5908C9.08144 73.1895 27.4013 91.5094 50 91.5094C72.5987 91.5094 90.9186 73.1895 90.9186 50.5908C90.9186 27.9921 72.5987 9.67226 50 9.67226C27.4013 9.67226 9.08144 27.9921 9.08144 50.5908Z" fill="#E5E7EB"/>
            <path d="M93.9676 39.0409C96.393 38.4038 97.8624 35.9116 97.0079 33.5539C95.2932 28.8227 92.871 24.3692 89.8167 20.348C85.8452 15.1192 80.8826 10.7238 75.2124 7.41289C69.5422 4.10194 63.2754 1.94025 56.7698 1.05124C51.7666 0.367541 46.6976 0.446843 41.7345 1.27873C39.2613 1.69328 37.813 4.19778 38.4501 6.62326C39.0873 9.04874 41.5694 10.4717 44.0505 10.1071C47.8511 9.54855 51.7191 9.52689 55.5402 10.0491C60.8642 10.7766 65.9928 12.5457 70.6331 15.2552C75.2735 17.9648 79.3347 21.5619 82.5849 25.841C84.9175 28.9121 86.7997 32.2913 88.1811 35.8758C89.083 38.2158 91.5421 39.6781 93.9676 39.0409Z" fill="currentColor"/>
          </svg>
          Processed ${this.filesProcessed}/${limit}
        `
      } else {
        uploadBtn.innerText = `Upload`
        uploadBtn.disabled = false
      }
      uploadBtn.classList.remove('hidden')
    }
  }

  async uploadFiles (event) {
    if(event)
      document.getElementById('upload-files').setAttribute('disabled', 'disabled')
    const body = {
      signed_ids: this.signedIdsValue,
      vendor_id: window.location.href.split('/').at(-1) || document.getElementById("newContract").dataset.vendorId
    };

    let endpoint = `/contracts`
    if(document.getElementById("newContract")) {
      const contractId = document.getElementById("newContract").dataset.contractId || window.location.href.split("/").at(-1)
      let sourceType = document.getElementById("newContract").dataset.sourceType
      if(sourceType == 'document') {
        endpoint = `/contracts/${contractId}/upload_file`
      }
    }

    const response = await post(endpoint, { body, dataType: "json" })
    if (response.ok) {
      if(this.redirectUrlOnSubmitValue) {
        window.location.href = this.redirectUrlOnSubmitValue
      } else {
        let blobs_data = this.dropzone.files.filter((f) => { return f.accepted }).map((f) => {
          let blob_id = f.previewElement.querySelector(".dz-remove").dataset.signedId
          return { status: 'uploading', type: '', name: f.upload.filename, blob_id: blob_id }
        })
        window.localStorage.setItem('uploadingDocs', JSON.stringify(blobs_data))
        syncProgressModal({ blobs: blobs_data.reverse()})
        showProgressModal()
        this.closeModal()
      }
    } else {
      console.log('something went wrong')
    }
  }
}
