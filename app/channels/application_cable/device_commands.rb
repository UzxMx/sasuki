module ApplicationCable
  module DeviceCommands
    def handle_commands(message)
      transmit message
    end
  end
end