require 'Pusher'
class StatusController < ApplicationController
  before_action :accept_all_params
  skip_before_action :verify_authenticity_token
  include Pusher

#  skip_before_filter :verify_authenticity_token, :if => Proc.new { |c| c.request.format == 'application/json' }
  #http://stackoverflow.com/questions/9362910/rails-warning-cant-verify-csrf-token-authenticity-for-json-devise-requests

  # GET /status
  # GET /status.json
  def index

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  #### Clear Logfile, called from Status-Page
  def clear
    Log.clear_all
#    PrivatePub.publish_to "/status", :chat_message => "Hello, world!"
    redirect_to :action => :index
  end

  def start_conversion
    Page.clean_pending
    Converter.run_conversion(Page.for_batch_conversion)
    redirect_to :action => :index
  end

  def trigger_backup
    BackupJob.perform_later
    redirect_to :action => :index
  end


  ## called by the hardware stack to read the server status and to display if any error
  def get_server_status
    render :json => Log.check_errors?
  end

  def get_docbox_status
    status_summary = Page.group(:status).count
    error = ""
    if Log.check_errors?
      error = "!!! ERROR !!!   "
    end
    message = error + "U:#{status_summary[Page::UPLOADED].presence || '0'} Cv:#{status_summary[Page::UPLOADED_PROCESSING].presence || '0'} OCR:#{pending_ocr = Page.uploading_status(:no_ocr)} S3:#{Page.uploading_status(:no_backup)}"
    render :json => message
  end


  def accept_all_params
    params.permit!
  end


end
