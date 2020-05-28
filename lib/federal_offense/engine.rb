# frozen_string_literal: true

require_dependency "federal_offense/interceptor"

module FederalOffense
  class Engine < ::Rails::Engine
    isolate_namespace FederalOffense

    class << self
      attr_accessor :server

      def cable_config
        @cable_config ||= ActionCable::Server::Configuration.new.tap do |config|
          config.logger = Rails.logger
          config.connection_class = -> { FederalOffense::ApplicationCable::Connection }
          config.mount_path = "cable"
        end
      end
    end

    # Register ourselves as an interceptor of outbound emails
    config.after_initialize do
      ActionMailer::Base.register_interceptor(FederalOffense::Interceptor)
    end

    # Set up ActionCable if the app has it loaded
    initializer "action_cable_connection" do |app|
      # Find cable configs
      federal_offense_config_path = Rails.root.join("config", "federal_offense_cable.yml")
      app_config_path = Rails.root.join("config", "cable.yml")

      # Determine which config we're going to use
      config = if File.exist?(federal_offense_config_path)
        app.config_for(federal_offense_config_path).with_indifferent_access
      elsif File.exist?(app_config_path)
        app.config_for(app_config_path).with_indifferent_access
      else
        # Default to an async cable cause whatever
        {adapter: "async"}
      end

      # Prefix the ActionCable configuration with a channel prefix (for benefit of separating app
      # and engine channels)
      # config[:channel_prefix] = [config[:channel_prefix], "federal_offense"].reject(&:blank?).join("_")

      # Assign the values to the cable config and create a server
      self.class.cable_config.cable = config
      self.class.server = ActionCable::Server::Base.new(config: self.class.cable_config)
      FederalOffense.action_cable = true
    end

    initializer "federal_offense.assets.precompile" do |app|
      app.config.assets.precompile += %w[federal_offense/application.css federal_offense/application.js federal_offense/cable.js]
    end
  end
end
