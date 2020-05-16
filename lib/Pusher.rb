module Pusher

  #render HTML via "render_anywhere", inside channel-js attach rendered message directly to dom-item
  def push_app_status
    message = ApplicationController.render partial: '/app_status'
    ActionCable.server.broadcast 'app_status_channel', content: message
  end

  # use js.erb file to generate javascript, inside channel-js execute this script (eval)
  def push_converted_page(page, local_conversion = false)
    message = ApplicationController.render partial: '/upload_sorting/converted_page', locals: {:page => page, :local_conversion => local_conversion}
    ActionCable.server.broadcast 'converted_page_channel', content: message
  end

  ## message-test is directly added to dom element in channel-js
  def push_scanner_status(message)
    ActionCable.server.broadcast 'scanner_status_update_channel', content: message
  end

end

