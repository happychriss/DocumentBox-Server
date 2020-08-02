module SearchHelper
  def search_class(page)
    doc=page.document
    result="preview"
    result=result+" new_document" if doc.removed?
    result=result+" no_delete" if (doc.no_delete? and not doc.pinned?)
    result=result+" more_pages" if doc.page_count>1
    result=result+" pinned" if (doc.pinned?)
#    result=result+" no_backup" unless doc.backup?
    return result
  end
end
