# frozen_string_literal: true

module FederalOffense
  module ActionCable
    def self.broadcast!(message: {reload: true})
      InboxChannel.broadcast!(message: message)
    end

    class Connection < ::ActionCable::Connection::Base
    end

    class InboxChannel < ::ActionCable::Channel::Base
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
end
