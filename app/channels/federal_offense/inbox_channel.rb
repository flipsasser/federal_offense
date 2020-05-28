# frozen_string_literal: true

module FederalOffense
  class InboxChannel < FederalOffense::ApplicationCable::Channel
    def self.broadcast!(message: {reload: true})
      FederalOffense::Engine.cable_server.broadcast(name, message)
    end

    def subscribed
      stream_from self.class.name
    end

    def unsubscribed
    end
  end
end
