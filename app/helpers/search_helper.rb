module SearchHelper
  def search_class(page)
    result="preview search_droppable"
    result=result+" search_draggable" if page.document_pages_count==1
    result=result+" new_document" if page.document.status==Document::DOCUMENT_FROM_PAGE_REMOVED
    result=result+" more_pages" if page.document_pages_count>1
#    result=result+" no_backup" unless page.document.backup?
    return result
  end
end
