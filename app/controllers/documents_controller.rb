class DocumentsController < ApplicationController
  before_action :accept_all_params

  # GET /documents/1/edit
  def edit
    @document = Document.includes(:pages).find(params[:id])
  end

  def index
    @docs=Document.where('delete_at is not null').order('delete_at asc')

  end

  def update
    @document = Document.find(params[:id])

    begin

        @document.update_attributes(params[:document])

      unless session[:search_results].nil?
            redirect_to session[:search_results]+"#page_#{@document.pages.first.id}", :notice => "Successfully updated doc."
      else
        redirect_to  root_url
        end
    rescue
      raise "ERROR"
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
    @document=@page.document

    @page.move_to_new_document

  end

  ### called in update document when the document is re-ordered
  def sort_pages
    params[:page].each_with_index do |page_id, position|
      page=Page.find(page_id)
      page.position=position
      page.save!
    end

    head :ok
  end

  ##### Maintain Pages

  def search_doc_id

    doc=Document.find(params[:q])
    if doc.nil? then
      flash[:error] = "Document not found"
      redirect_to :action => 'index'
    else
      redirect_to edit_document_url(doc.id)
    end
  end

  def search_page_id

    page=Page.find(params[:q])
    if page.nil?
      flash[:error] = "Page not found"
      redirect_to :action => 'index'
      return true
    end

    doc=page.document
    if doc.nil?
      flash[:error] = "Page found, but no document"
      redirect_to :action => 'index'
      return true
    end

    redirect_to edit_document_url(doc.id)

  end

  def delete_documents
    flash[:notice] = "Deleting documents end of lifecycle triggered"
    RemoveFromArchiveWorker.perform_async
    redirect_to :action => 'index'
  end

  def search_archive
  end

  def accept_all_params
    params.permit!
  end


end
