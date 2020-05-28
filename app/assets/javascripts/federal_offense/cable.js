//= require ./vendor/action_cable

const consumer = ActionCable.createConsumer()
consumer.subscriptions.create("FederalOffense::InboxChannel", {
  connected: () => {
    /* NOOP */
  },
  disconnected: () => {
    /* NOOP */
  },
  received(data) {
    if (data.reload) {
      window.location.reload()
    } else if (data.location) {
      window.location = data.location
    }
  },
})
