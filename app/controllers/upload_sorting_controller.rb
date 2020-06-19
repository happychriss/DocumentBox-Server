require 'Pusher'


class UploadSortingController < ApplicationController
  include Pusher
  before_action :accept_all_params

  def new

    @document = Document.new
    @document.created_at = Date.today.strftime("%d.%m.%Y")

    respond_to do |format|
      format.html { @pages = Page.uploaded_pages.order(id: :asc) } # new.html.erb
      format.js { @pages = nil } #new from ajax
    end
  end


  ###################### Create a new document with pages, action is called via Javascript app/assets/javascripts/upload_sorting_new.js
  def create


    if params[:page].nil?
      head :ok
    return
    end

    Document.transaction do
      begin

        @document = Document.new(params[:document])
        @document.status = Document::DOCUMENT_NOT_ARCHIVED unless params.key?(:id_upload_btn) #only PDF, no backup needed
        @document.save!

        params[:page].each_with_index do |page_id, position|
          p = Page.find(page_id)
          p.add_to_document(@document, position)
        end

        Log.write_status('ServerCreateDoc', "Created document with #{@document.reload.page_count} pages!")
      rescue
        Log.write_error('ServerCreateDoc', "ERROR creating document: #{@document.errors.full_messages }!")
        raise
      end

    end

    ## backup new document to Amazon
    if params.key?(:id_upload_btn)
      BackupJob.perform_later(@document.id)
      @pdf_name=""
      render action: "new"
  ## create PDF only and use download_pdf
   else
      pdf_file=@document.pdf_file ## generate the PDF
      @pdf_name=File.basename(pdf_file)
      render action: "new"
    end

    push_app_status

  end

  ##### NON HABTM Action

  ### action called from "new.js.erb to send the file to the client, only possible via upload
  def download_pdf
    document = Document.find(params[:id])
    pdf=document.pdf_file
    send_file(pdf.path, :type => 'application/pdf', :page => '1')
    pdf.close
    document.destroy if document.status ==Document::DOCUMENT_NOT_ARCHIVED #not needed anymore
    push_app_status
  end

  #### Action triggered by CDClient UPload program


  def destroy_page
    @page = Page.find(params[:id])
    @page.destroy_with_file
  end

  private

  def accept_all_params
    params.permit!
  end



end
