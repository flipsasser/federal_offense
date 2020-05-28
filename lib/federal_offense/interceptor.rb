# frozen_string_literal: true

module FederalOffense
  class Interceptor
    def self.delivering_email(message)
      FederalOffense::Message.create(message)
      FederalOffense::InboxChannel.broadcast!
    end
  end
end
