class DocumentsController < ApplicationController
  before_action :accept_all_params
  skip_before_action :verify_authenticity_token

  # GET /documents/1/edit
  def edit
    @document = Document.includes(:pages).find(params[:id])
  end

  def index
    @docs = Document.where('delete_at is not null').order('delete_at asc')

  end

  def update

    # check for cancel first

    @document = Document.find(params[:id])
    last_page = false

    if params[:name_upl].nil?

      Document.transaction do

        @document.status = Document::DOCUMENT if @document.status == Document::DOCUMENT_FROM_PAGE_REMOVED #document was changed by user
        @document.update(params[:document])
        @document.save

        # Sort pages based on order

        params[:order_pages].each_with_index do |page_id, position|
          page = Page.find(page_id)
          page.position = position
          page.save!
        end unless params[:order_pages].nil?

        # Delete pages
        params[:delete_pages].each do |page_id|
          last_page = Page.find(page_id).destroy_with_file
        end unless params[:delete_pages].nil?

        # Remove pages
        params[:remove_pages].each do |page_id|
          Page.find(page_id).move_to_new_document
        end unless params[:remove_pages].nil?

      end

    end
    if session[:search_results].nil?
      redirect_to root_url
    elsif last_page
      redirect_to session[:search_results]
    else
      redirect_to session[:search_results] + "#page_#{@document.pages.first.id}", :notice => "Successfully updated doc."
    end

  end

  def destroy_page
    @page = Page.find(params[:id])
    @page.destroy_with_file

    respond_to do |format|
      format.html { redirect_to search_url }
      format.js {}
    end

  end

  ################################### non HABTM ################################################


  ### UPDATE Document

  ## remove a page from the document via the edit action
  def remove_page

    @page = Page.find(params[:id])
    @document = @page.document

    @page.move_to_new_document

  end

  ### called in update document when the document is re-ordered
  def sort_pages
    params[:page].each_with_index do |page_id, position|
      page = Page.find(page_id)
      page.position = position
      page.save!
    end

    head :ok
  end

  ##### Maintain Pages

  def search_doc_id

    doc = Document.find(params[:q])
    if doc.nil? then
      flash[:error] = "Document not found"
      redirect_to :action => 'index'
    else
      redirect_to edit_document_url(doc.id)
    end
  end

  def search_page_id

    page = Page.find(params[:q])
    if page.nil?
      flash[:error] = "Page not found"
      redirect_to :action => 'index'
      return true
    end

    doc = page.document
    if doc.nil?
      flash[:error] = "Page found, but no document"
      redirect_to :action => 'index'
      return true
    end

    redirect_to edit_document_url(doc.id)

  end

  def delete_documents
    flash[:notice] = "Deleting documents end of lifecycle triggered"
    RemoveFromArchiveJob.perform_async
    redirect_to :action => 'index'
  end

  def search_archive
  end

  def accept_all_params
    params.permit!
  end


end
