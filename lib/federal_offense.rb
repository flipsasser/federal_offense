# frozen_string_literal: true

require "federal_offense/version"

module FederalOffense
  class << self
    attr_accessor :action_cable
  end
end

require "federal_offense/engine" if defined? Rails
