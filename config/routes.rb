Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  post 'devices/:device_id/info' => 'devices#info'
  post 'devices/:device_id/upload_logs' => 'devices#upload_logs'
  post 'devices/:device_id/configure_logger' => 'devices#configure_logger'
end
