# frozen_string_literal: true

module GenerateMessage
  def self.included(base)
    base.let(:messages) { FederalOffense::Message.all }
    base.let(:message) { messages.first }
  end

  def generate_message(method = :user_update)
    BoringMailer.send(method).deliver
  end

  def generate_messages(n, method = :user_update)
    now = Time.zone.now

    Array.new(n) do |i|
      minutes = ((n - i) * 15).minutes
      Timecop.freeze(minutes.before(now))
      generate_message(method).tap { Timecop.return }
    end
  end
end

RSpec.configure do |config|
  config.include GenerateMessage
end
