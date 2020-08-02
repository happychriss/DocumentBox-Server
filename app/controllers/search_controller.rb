
class SearchController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :accept_all_params

  def search
    @current_keywords||= []
    @sort_mode||= :time
  end

  def found

    session[:search_results] = request.url
    session[:sort_mode]=params[:sort_mode]
    @sort_mode=params[:sort_mode].to_sym

    @current_keywords=params[:document].nil? ? []:params[:document][:keyword_list]

    @documents_removed=Document.where(status: Document::DOCUMENT_FROM_PAGE_REMOVED)
    @documents=Document.search_index(params[:q],@current_keywords, params[:page],@sort_mode)

    @q=params[:q]

    render :action => 'search'

end


  def pin_document
    document=Document.find(params[:id])
    document.create_pinned_document
    @page=document.cover_page
  end

  def unpin_document
    document=Document.find(params[:id])
    document.pinned_document.destroy
    @page=document.cover_page
  end

  ## add a page to the document via drag and drop (from search screen)
  def add_page
    drag_id=params[:drag_id][/\d+/].to_i
    drop_id=params[:drop_id][/\d+/].to_i #I get the new page

    @drag_page=Page.find(drag_id)
    @drop_page=Page.find(drop_id)

    @drag_page.add_to_document(@drop_page.document)
    @drop_page.reload
    return "404"
  end

  ### Show document PDF and RTF

  def show_rtf
    @page=Page.find(params[:id])
  end

  def show_pdf_page
    page=Page.find(params[:id])
    send_file(page.pdf_path, :filename => page.pretty_filename(:pdf),:type => 'application/pdf', :page => '1')
  end

  def show_pdf_document
    document=Document.find(params[:id])
    pdf=document.pdf_file
    send_file(pdf.path, :filename => document.pretty_filename,:type => 'application/pdf', :page => '1')
    pdf.close
  end

  def show_original
    page=Page.find(params[:id])
    data=File.read(page.path(:org))
     send_data( data, :filename => page.pretty_filename(:org),:type => page.mime_type, :page => '1' )
  end

  def show_document_pages
    @pages=Document.find(params[:id]).pages.limit(4)
  end

  def accept_all_params
    params.permit!
    response.headers['SameSite'] = 'Lax'
  end

end



