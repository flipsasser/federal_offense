# frozen_string_literal: true

require_dependency "federal_offense/interceptor"

module FederalOffense
  class Engine < ::Rails::Engine
    isolate_namespace FederalOffense

    class << self
      attr_accessor :cable_server

      def cable_config
        @cable_config ||= ActionCable::Server::Configuration.new.tap do |config|
          config.logger = Rails.logger
          config.connection_class = -> { FederalOffense::ApplicationCable::Connection }
          config.mount_path = "cable"
        end
      end
    end

    # Precompile the assets we need to run this thing
    initializer "federal_offense.assets.precompile" do |app|
      app.config.assets.precompile += %w[federal_offense/application.css federal_offense/application.js federal_offense/cable.js]
    end

    # Register as an interceptor of outbound emails
    initializer "action_mailer" do |app|
      if Rails.env.production?
        abort %{[FEDERAL OFFENSE] CRITICAL NIGHTMARE SCENARIO: YOU INSTALLED FEDERAL OFFENSE IN PRODUCTION\n\nPlease ensure `gem "federal_offense"` appears only in your development Gemfile group (and maybe test, but even that's stretching it).}
      end

      ActionMailer::Base.register_interceptor(FederalOffense::Interceptor)
    end

    # Enable ActionCable connections in the inbox for auto-reload
    initializer "action_cable_connection" do |app|
      if defined? ActionCable
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

        # Assign the values to the cable config and create a server
        self.class.cable_config.cable = config
        self.class.cable_server = ActionCable::Server::Base.new(config: self.class.cable_config)
        FederalOffense.action_cable = true
      end
    end
  end
end
