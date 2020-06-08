require 'fileutils'
require 'Pusher'


class UploadsController < ApplicationController
  before_action :accept_all_params
  skip_before_action :verify_authenticity_token
  include Pusher

  begin

    ########################################################################################################
    ############ Status Updates

    ### called from scanner, this will trigger the Pusher in view
    def scan_status
      @message = params[:message]
      @scan_complete = (params[:scan_complete] == 'true')
      TouchSwitch.send_status(@message, @scan_complete)
      push_scanner_update(@message,nil,@scan_complete)
      head :ok
    end

    ### called from converter, this will trigger the Pusher in view
    def convert_status
      @message=params[:message]
      push_converter_update(@message)
      head :ok
    end

    ########################################################################################################
    ############ NEW FILES provided by Scanner or Upload

    ### Upload from CDClient (Scanner) - file uploaded as JPG - single pages as jpg
    def create_from_scanner_jpg

      @page = Page.new
      @page.original_filename = params[:upload_file].original_filename
      @page.position = 0
      @page.source = Page::PAGE_SOURCE_SCANNED
      @page.mime_type = 'image/jpeg'
      @page.status = Page::UPLOADED
      @page.save!

      ## Copy to docstore
      @page.save_file(params[:upload_file], :org)

      ## just if provided in addition, we are happy, will be _s.jpg

      @page.save_file(params[:small_upload_file], :s_jpg) unless params[:small_upload_file].nil?

      ## Background: create smaller images and pdf  and text

      Hardware.update_status_leds

      Converter.run_conversion([@page.id])

      Hardware.blink_ok_status_led

      ## this triggers the pusher to update the page with new uploaded data
      push_scanner_update("New Scanner File",@page)

      head :ok

    end

    ## file will be saved as PDF, not JPG
    def create_from_mobile_jpg

      upload_file = params[:upload_file]

      page = Page.new(
          :original_filename => File.basename(upload_file.original_filename),
          :source => Page::PAGE_SOURCE_MOBILE,
          :mime_type => 'image/jpeg')

      page.save!
      page.reload

      ## Copy to docstore and update DB -- will be .scanned.jpg

      page.save_file(upload_file, :org)

      Converter.run_conversion([page.id])

      head :ok

    end

    #### Upload file directly from DBServer via Upload Dialogue
    def create_from_upload

      if params[:file_upload].nil? or params[:file_upload][:my_file].nil?
        flash[:error] = "No filename entered."
        render :action => 'new'
        return
      end

      upload_file = params[:file_upload][:my_file]

      unless Page::PAGE_MIME_TYPES.has_key?(upload_file.content_type)
        flash[:error] = "File format not supported, detected type: ****** #{upload_file.content_type} ******- supportet tpyes: #{Page::PAGE_MIME_TYPES.to_s}."
        render :action => 'new'
        return
      end

      page = Page.new(
          :original_filename => upload_file.original_filename,
          :source => Page::PAGE_SOURCE_UPLOADED,
          :mime_type => upload_file.content_type)

      page.save!
      page.reload

      page.save_file(upload_file, :org)

      Converter.run_conversion([page.id])

      redirect_to new_upload_path, notice: 'Upload was successfully created.'

    end


    ########################################################################################################
    ############ CONVERTED FILES Provided


    ### called from converter, when preview images are created
    def convert_upload_preview_jpgs

      page=Page.find(params[:page][:id])
      page.save!

      page.save_file(params[:page][:result_jpg], :jpg)
      page.save_file(params[:page][:result_sjpg], :s_jpg)

      push_converter_update("Preview converted",page)

      head :ok

    end

    ### called from converter, when document is converted
    def convert_upload_pdf

      page=Page.find(params[:page][:id])
      page.content=params[:page][:content]
      page.status=Page::UPLOADED_PROCESSED
      page.mime_type='application/pdf' if page.calc_pdf_as_org?
      page.ocr=true

      ### check if we have a PDF for the page available, either as org file or created in addition
      if page.calc_pdf_as_org? or params[:page][:pdf_data]!=""
        page.pdf_exists=true
      end

      page.save_file(params[:page][:org_data], :org) ##this is pdf in case of scanned, otherwise JPG
      page.save_file(params[:page][:pdf_data], :pdf) unless params[:page][:pdf_data]=="" #if JPG, this is the PDF as extra

      page.save!

       ## send status-update to application
      push_converter_update("Converted",page)

      head :ok

    end


    ########################################################################################################
    ############ Respond to Mobile Upload

    ### called from mobile device to check if DBServer is available
    def cd_server_status_for_mobile
      head :ok
    end


  rescue Exception => e
    Log.write_error('UploadsController', e.message)
    raise
  end

  def accept_all_params
    params.permit!
  end

end
