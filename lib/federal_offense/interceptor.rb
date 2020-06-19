# frozen_string_literal: true

module FederalOffense
  class Interceptor
    def self.delivering_email(message)
      FederalOffense::Message.create(message)
      FederalOffense::ActionCable.broadcast! if FederalOffense.action_cable
    end
  end
end
