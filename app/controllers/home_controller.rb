class HomeController < ApplicationController
  def index
    Psub.server.broadcast("devices", {data: 'hello'})
  end

  def subscribe
    if session[:subscribe_info].nil?
      message_callback = -> message do
        logger.info "message:#{message}"
      end
      wrapped_callback = Psub.server.subscribe("from_captain:devices:1", message_callback)
      session[:subscribe_info] = wrapped_callback
      puts "session info"
      puts session[:subscribe_info]
    else
      logger.info "already subscribed"
    end

    render 'index'
  end

  def unsubscribe
    if session[:subscribe_info].nil?
      logger.info "already unsubscribed"
    else
      puts "session info"
      puts session[:subscribe_info]
      Psub.server.unsubscribe("from_captain:devices:1", session[:subscribe_info])
      session[:subscribe_info] = nil
    end

    render 'index'
  end
end
