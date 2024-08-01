import consumer from "./consumer"
import { get } from "@rails/request.js"
import '../file_upload_progress_modal'

const storage = window.localStorage

loadTurbo = async () => {
  const response = await get('/contract_files.json')
  if(response.ok) {
    response.json.then((data) => {
      files = data.files
      docs = JSON.parse(storage.getItem('uploadingDocs')) || []
      docs = docs.filter((doc) => {
        return files.filter((file) => { return file.blob_id == doc.blob_id }).length == 0
      })
      storage.setItem('uploadingDocs', JSON.stringify(docs))
      console.log(docs.concat(files))
      syncProgressModal({ blobs: docs.concat(files) }, 'append')
    })
  }
}

consumer.subscriptions.create("FileChannel", {
  connected() {
    // Called when the subscription is ready for use on the server
    console.log('connected[FileChannel]')
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
    console.log('disconnected[FileChannel]')
  },

  received(data) {
    // Called when there's incoming data on the websocket for this channel
    loadTurbo()
  }
});
