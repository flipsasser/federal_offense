# frozen_string_literal: true

RSpec.configure do |config|
  config.before do
    FederalOffense::Message.destroy_all
  end
end
