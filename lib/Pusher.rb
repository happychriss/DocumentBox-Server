module Pusher

  #render HTML via "render_anywhere", inside channel-js attach rendered message directly to dom-item
  def push_app_status
    puts "PUSHER: App Status START ***************************"
    message = ApplicationController.render partial: '/app_status'
    ActionCable.server.broadcast 'app_status_channel', content: message
    puts "PUSHER: App Status END ***************************"
  end

  def push_upload_update(update_source,result_message='',page=nil,scan_complete=false)
    puts "PUSHER: #{update_source} Upload Update START: #{result_message} *********************"
    push_app_status

    page_html=''
    page_id=''

    unless page.nil?
      page_html = ApplicationController.render partial: 'uploads/page_uploaded', :locals => {:page => page}
      page_id=page.id
    end

    ActionCable.server.broadcast 'upload_update_channel',
                                 update_source: update_source,
                                 page_html: page_html,
                                 page_id: page_id,
                                 result_message: result_message,
                                 scan_complete: scan_complete

    puts "PUSHER: Upload Update END *********************"
  end


end

