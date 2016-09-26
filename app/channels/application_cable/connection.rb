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

      device.status_records = status_changed(device, true)

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
      self.psub_callback = Psub.server.subscribe("from_captain:devices:#{device.id}", message_callback)

      # inform device appearance
      Psub.server.broadcast("from_devices:devices", type: "appearance", device_id: current_device.id)
    end

    def disconnect
      logger.debug "disconnect"

      logger.debug "current_device:#{current_device}"

      current_device.online = false
      current_device.status_records = status_changed(current_device, false)
      current_device.save!

      # unregister sub
      Psub.server.unsubscribe("from_captain:devices:#{current_device.id}", psub_callback)

      #inform device disappearance
      Psub.server.broadcast("from_devices:devices", type: "disappearance", device_id: current_device.id)
    end

    private
      def message_from_captain(message)
        logger.debug "message:#{message}"

        handle_commands(message)
      end

      def status_changed(device, online)
        status_records_in_json = nil

        status_changed_time = Time.now
        today_status_records_key = status_changed_time.strftime('%Y-%m-%d')
        today_status_records_in_json = nil
        status_records_str = device.status_records

        if !status_records_str.nil? and !status_records_str.empty?
          status_records_in_json = JSON.parse(status_records_str)
        end

        if status_records_in_json.nil?
          status_records_in_json = {}
        else
          today_status_records_in_json = status_records_in_json[today_status_records_key]
        end

        if today_status_records_in_json.nil?
          today_status_records_in_json = {}
          status_records_in_json[today_status_records_key] = today_status_records_in_json
        end

        status_record_key = status_changed_time.strftime('%H:%M:%S')
        today_status_records_in_json[status_record_key] = online ? 1 : 0

        JSON.generate(status_records_in_json)
      end
  end
end
