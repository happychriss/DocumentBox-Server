module SearchHelper
  def search_class(page)
    result="preview"
    result=result+" new_document" if page.document.status==Document::DOCUMENT_FROM_PAGE_REMOVED
    result=result+" no_delete" if page.document.no_delete?
    result=result+" more_pages" if page.document_pages_count>1
#    result=result+" no_backup" unless page.document.backup?
    return result
  end
end
