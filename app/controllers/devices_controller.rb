class DevicesController < ApplicationController
  before_action :authenticate

  def info
    process_device_info(params[:user_info], params[:device_info])

    send_notification(@current_device.id, type: 'get_device_info', device_info: JSON.parse(@current_device.info), user_info: { username: @current_device.username }, updated_at: @current_device.updated_at.strftime("%Y-%m-%d %H:%M:%S %z"))

    render json: {
      status: 1
    }
  end

  def upload_logs
    device_logs_dir = Rails.application.device_logs_dir
    dir = File.join(device_logs_dir, "#{@current_device.id}")
    if !File.exists?(dir)
      FileUtils.makedirs(dir)
    end

    file_count = params[:file_count].to_i
    last_filename = nil
    last_file = nil
    for i in 0..(file_count - 1)
      uploaded_file = params["log#{i}"]
      date = Date.strptime(uploaded_file.original_filename, "%Y%m%d%H%M%S.log")
      filename = date.strftime("%Y-%m-%d") + ".log"

      logger.debug "filename:#{filename}"

      if filename != last_filename
        unless last_file.nil?
          last_file.close
        end
        path = File.join(dir, filename)
        file = File.open(path, "ab")
      else
        file = last_file
      end

      file.write(uploaded_file.read)
      last_filename = filename
      last_file = file
    end

    unless last_file.nil?
      last_file.close
    end

    send_notification(@current_device.id, type: "fetch_device_logs")

    render json: {
      status: 1
    }
  end

  def configure_logger
    process_device_info(params[:user_info], params[:device_info])

    send_notification(@current_device.id, type: 'configure_logger', device_info: JSON.parse(@current_device.info), user_info: { username: @current_device.username}, updated_at: @current_device.updated_at.strftime("%Y-%m-%d %H:%M:%S %z"))

    render json: {
      status: 1
    }
  end

  private
    def process_device_info(user_info, device_info)
      if !user_info.nil? && !user_info['username'].empty?
        @current_device.username = user_info['username']
      end

      @current_device.info = JSON.generate(device_info.to_unsafe_h)

      @current_device.save!      
    end

    def send_notification(device_id, message = {})
      Psub.server.broadcast("from_devices:devices:#{device_id}", message)
    end
end
