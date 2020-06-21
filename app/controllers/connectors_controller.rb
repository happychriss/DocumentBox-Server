require 'Pusher'

class ConnectorsController < ApplicationController
  include Pusher
  skip_before_action :verify_authenticity_token
  before_action :accept_all_params


#  skip_before_filter :verify_authenticity_token, :if => Proc.new { |c| c.request.format == 'application/json' }
  #http://stackoverflow.com/questions/9362910/rails-warning-cant-verify-csrf-token-authenticity-for-json-devise-requests

  # GET /connections
  # GET /connections.json
  def index
    @connectors = Connector.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @connectors }
    end
  end

  def show
    redirect_to :action => :index
  end

  # POST /connections
  # POST /connections.json
  def create

    service= params[:connector][:service]

    case service
      when 'Scanner'
        Scanner.connect(params[:connector])
      when 'Converter'
        Converter.connect(params[:connector])
        sleep(0.5) ##just to avoid to much going on in parallel, should not be needed, just better
        Converter.run_conversion(Page.for_batch_conversion)
      when 'Hardware'
        Hardware.connect(params[:connector])
        sleep(0.5)
        Hardware.blink_ok_status_led
        Hardware.watch_scanner_button_on
     when 'TouchSwitch'
       TouchSwitch.connect(params[:connector])
     else
        raise "Create Connection with unkown service: #{service}"
    end

   push_app_status
    head :ok
  end

  # DELETE /connections/1
  # DELETE /connections/1.json
  def destroy
    @connector = Connector.find(params[:id])
    @connector.destroy unless @connector.nil?

    respond_to do |format|
      format.html { render 'status/index'}
      format.json { render nothing: true }
    end

    push_app_status

  end


  def accept_all_params
    params.permit!
  end


end
