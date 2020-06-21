ThinkingSphinx::Index.define(:document,  :with => :active_record,  :delta => true  )  do
  indexes comment, :as => :comment
  indexes pages.content, :as => :page_content
  has taggings.tag_id, :as => :tags
  has created_at, :sortable => true
  has status
  where "documents.status!=#{Document::DOCUMENT_FROM_PAGE_REMOVED}"
end