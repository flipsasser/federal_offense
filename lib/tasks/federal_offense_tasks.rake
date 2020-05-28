# frozen_string_literal: true

namespace :federal_offense do
  desc "Clear out the cached messages in Federal Offense"
  task clear_inbox: :environment do
    require "federal_offense"
    FederalOffense::Message.destroy_all
  end
end
