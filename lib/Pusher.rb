module Pusher

  #render HTML via "render_anywhere", inside channel-js attach rendered message directly to dom-item
  def push_app_status
    puts "PUSHER: App Status ***************************"
    message = ApplicationController.render partial: '/app_status'
    ActionCable.server.broadcast 'app_status_channel', content: message
    puts "PUSHER: App Status ***************************"
  end

  def push_converter_update(convert_message,page=nil,local_conversion=false)
    puts "PUSHER: Converter Update *********************"
    push_app_status
    content = ApplicationController.render partial: '/uploads/converter_update', locals: {:page => page, :local_conversion => local_conversion, :message=> convert_message}
    ActionCable.server.broadcast 'converter_update_channel', content: content
    puts "PUSHER: Converter Update *********************"
  end

  def push_scanner_update(scan_message,page=nil,scan_complete=false)
    puts "PUSHER: Scanner Update ***********************"
    push_app_status
    content = ApplicationController.render partial: '/uploads/scanner_update', locals: {:page => page, :scan_complete => scan_complete, :message=> scan_message}
    ActionCable.server.broadcast 'scanner_update_channel', content: content
    puts "PUSHER: Scanner Update ***********************"
  end


end

