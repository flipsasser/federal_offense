# frozen_string_literal: true

module FederalOffense
  module ApplicationHelper
    def message_array(input)
      return "(none)" if input.blank?
      Array(input).compact.to_sentence
    end
  end
end
