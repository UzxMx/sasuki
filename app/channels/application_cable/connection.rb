# Be sure to restart your server when you modify this file. Action Cable runs in a loop that does not support auto reloading.
module ApplicationCable
  class Connection < ActionCable::Connection::Base
    include DeviceCommands

    identified_by :current_device

    attr_accessor :psub_callback

    def beat
      websocket.transmit "b"
    end

    def connect
      logger.debug "connect"

      app_id = env["HTTP_X_APPLICATION_ID"]
      device_id = env["HTTP_X_DEVICE_ID"]

      application = Application.where({ app_id: app_id }).first
      device = Device.where({ application: application, device_id: device_id }).first
      if device.nil?
        device = Device.new({
          device_id: device_id
        })
      end
      device.application = application
      device.online = true

      if device.auth_token.empty?
        device.auth_token = SecureRandom.uuid
      end

      device.save!

      self.current_device = device

      transmit type: "auth_info", data: {
        id: device.id,
        auth_token: device.auth_token
      }

      # register sub
      message_callback = -> message do
        message_from_captain(message)
      end
      psub_callback = Psub.server.subscribe("from_captain:devices:#{device.id}", message_callback)

      # inform device appearance
      Psub.server.broadcast("from_devices:devices", type: "appearance", device_id: current_device.id)
    end

    def disconnect
      logger.debug "disconnect"

      logger.debug "current_device:#{current_device}"

      current_device.online = false
      current_device.save!

      # unregister sub
      Psub.server.unsubscribe("from_captain:devices#{current_device.id}", psub_callback)

      #inform device disappearance
      Psub.server.broadcast("from_devices:devices", type: "disappearance", device_id: current_device.id)
    end

    private
      def message_from_captain(message)
        logger.debug "message:#{message}"

        handle_commands(message)
      end
  end
end
