require 'fileutils'
require 'Pusher'


class UploadsController < ApplicationController
  before_action :accept_all_params
include Pusher

  begin

    #### Upload file directly from DBServer via Upload Dialogue
    def create_from_upload

      if params[:file_upload].nil? or params[:file_upload][:my_file].nil?
        flash[:error] = "No filename entered."
        render :action => 'new'
        return
      end

      upload_file= params[:file_upload][:my_file]

      unless Page::PAGE_MIME_TYPES.has_key?(upload_file.content_type)
        flash[:error] = "File format not supported, detected type: ****** #{upload_file.content_type} ******- supportet tpyes: #{Page::PAGE_MIME_TYPES.to_s}."
        render :action => 'new'
        return
      end

      page=Page.new(
          :original_filename => upload_file.original_filename,
          :source => Page::PAGE_SOURCE_UPLOADED,
          :mime_type => upload_file.content_type)

      page.save!
      page.reload

      page.save_file(upload_file, :org)

      Converter.run_conversion([page.id])

      redirect_to new_upload_path, notice: 'Upload was successfully created.'

    end

    ### Upload from CDClient (Scanner) - file uploaded as JPG - single pages as jpg
    def create_from_scanner_jpg

      @page = Page.new
      @page.original_filename=params[:upload_file].original_filename
      @page.position=0
      @page.source=Page::PAGE_SOURCE_SCANNED
      @page.mime_type='image/jpeg'
      @page.status=Page::UPLOADED
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
      render('create_from_scanner_jpg', :handlers => [:erb], :formats => [:js])

    end


    ### called from mobile device to check if DBServer is available
    def cd_server_status_for_mobile
      head :ok
    end


    ## file will be saved as PDF, not JPG
    def create_from_mobile_jpg

      upload_file=params[:upload_file]

      page=Page.new(
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

  rescue Exception => e
    Log.write_error('UploadsController', e.message)
    raise
  end

  def accept_all_params
    params.permit!
  end

end
