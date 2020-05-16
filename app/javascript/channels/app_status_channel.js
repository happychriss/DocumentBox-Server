import consumer from "./consumer"

consumer.subscriptions.create("AppStatusChannel", {
  connected() {
    // Called when the subscription is ready for use on the server
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    // Called when there's incoming data on the websocket for this channel
    const element=document.getElementById("application_status");
//    newEl.innerHTML = data.content
//    element.insertAdjacentHTML("beforeend", data.content)
    element.innerHTML=data.content

  }
});
