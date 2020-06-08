require 'Pusher'

class ScannersController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :accept_all_params
  include Pusher

#  skip_before_filter :verify_authenticity_token, :if => Proc.new { |c| c.request.format == 'application/json' }
  #http://stackoverflow.com/questions/9362910/rails-warning-cant-verify-csrf-token-authenticity-for-json-devise-requests


  #### scanner to list devices - called via remote link
  def scan_info
    @scanner_device_list=Scanner.connected_devices
    respond_to do |format|
      format.js  # index.html.erb
      format.json { render :json => @scanner_device_list }
    end

      #DETE: respond_to(:js) #scan_info.js.erb
  end


  def start_scanner

    color=!params[:color].nil?
    scanner_name=params[:scanner_name]
    Scanner.start_scan(scanner_name, color)
    push_app_status ## send status-update to application main page via private_pub gem, fayes,

    respond_to(:js)
  end

  def start_scanner_from_hardware

    scanner_device_list=Scanner.connected_devices

    if scanner_device_list.count>0
      Scanner.start_scan(scanner_device_list.first[1], Scanner::COLOR_MODE_ON)
    else
      Hardware.set_ok_status_led(:off)
      Hardware.blink_yellow_status_led
    end

     render :json => scanner_device_list

  end


  def start_copy_from_hardware
    scanner_device_list=Scanner.connected_devices

    if scanner_device_list.count>0
      Scanner.start_copy(scanner_device_list.first[1])
    else
      Hardware.set_ok_status_led(:off)
      Hardware.blink_yellow_status_led
    end

    render :json => scanner_device_list

  end


  def accept_all_params
    params.permit!
  end

end
