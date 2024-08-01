import consumer from "./consumer"
import { get } from "@rails/request.js"

updateHeader = () => {
  if($('.right-nav .upgrade-info').length > 0) {
    $('.right-nav').children(':not(.upgrade-info)').remove()
    $('.right-nav .upgrade-info').removeClass('hidden')
  }
}

consumer.subscriptions.create("ContractChannel", {
  connected() {
    // Called when the subscription is ready for use on the server
    console.log('connected[ContractChannel]', window.location.pathname)
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
    console.log('disconnected[ContractChannel]')
  },

  received(data) {
    // Called when there's incoming data on the websocket for this channel
    broadcastData = data['data']
    if(data['action'] == 'force_relaod') {
      location.reload()
    } else if(data['action'] == 'created'){
    } else if(data['action'] == 'first_contract' || data['action'] == 'first_active_contract') {
      if(window.location.pathname == '/') {
        location.reload()
      }
    } else if(data['action'] == 'limit_reached') {
      updateHeader()
    }
  }
});
