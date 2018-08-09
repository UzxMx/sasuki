require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Sasuki
  class Application < Rails::Application
    config.before_configuration do
      env_file = Rails.root.join('config', 'local_env.yml')
      if File.exist?(env_file)
        result = YAML.load(File.read(env_file))
        if result.is_a?(Hash)
          result.each do |key, value|
            ENV[key.to_s] = value.try(&:to_s) || ''
          end
        end
      end
    end

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    def device_logs_dir
      @device_logs_dir ||= File.join(ENV['HOME'], 'sasuki', 'logs')
    end
  end
end

module ActionCable
  module Server
    module Connections
      def setup_heartbeat_timer
        @heartbeat_timer ||= event_loop.timer(30) do
          event_loop.post { connections.map(&:beat) }
        end
      end      
    end
  end
end
