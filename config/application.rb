require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Sasuki
  class Application < Rails::Application
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
