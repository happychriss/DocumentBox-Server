require 'Pusher'

class ConvertersController < ApplicationController
  include Pusher
  before_action :accept_all_params
  skip_before_action :verify_authenticity_token

  ### called from converter, this will trigger the Pusher in view
  def convert_status
    @message=params[:message]
    push_scanner_status(@message)
    head :ok

  end


  ### called from converter, when preview images are created
  def convert_upload_preview_jpgs

    page=Page.find(params[:page][:id])
    page.save!

    page.save_file(params[:page][:result_jpg], :jpg)
    page.save_file(params[:page][:result_sjpg], :s_jpg)

    push_app_status ## send status-update to application main page via private_pub gem, fayes,
    push_converted_page(page)

    head :ok

  end

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

    push_app_status ## send status-update to application main page via private_pub gem, fayes,
    push_converted_page(page)

    head :ok

  end

  def accept_all_params
    params.permit!
  end

end
