# frozen_string_literal: true

RSpec.configure do |config|
  # Include I18n helpers in tests so we can write assertions against expected content
  config.include AbstractController::Translation
end
