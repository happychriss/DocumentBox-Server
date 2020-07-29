class Page < ActiveRecord::Base

  ## adds function short_path and path to page
  require 'FileSystem'
#  require 'aws/s3'
  require 'aws-sdk-s3' #NEW

  include FileSystem
  include ThinkingSphinx::Scopes


  attr_accessor :upload_file

  belongs_to :document, optional: true
  belongs_to :org_folder, :class_name => 'Folder', optional: true
  belongs_to :org_cover, :class_name => 'Cover', optional: true


#### Page Status flow
  UPLOADED = 0 # page just uploaded, waiting for processing
  UPLOADED_PROCESSING = 1 # pages is being processed (OCR)
  UPLOADED_PROCESSED = 3 # pages was processed by worker (content added)


  PAGE_SOURCE_SCANNED = 0
  PAGE_SOURCE_UPLOADED = 1
  PAGE_SOURCE_MOBILE = 2
  PAGE_SOURCE_MIGRATED = 99

  PAGE_FORMAT_PDF = 0
  PAGE_FORMAT_SCANNED_JPG = 1

  PAGE_PREVIEW = 1
  PAGE_NO_PREVIEW = 0


##
  PAGE_DEFAULT_SCAN_MIME_TYPE = 'application/pdf'

  PAGE_MIME_TYPES = {'application/pdf' => :PDF,
                     'application/msword' => :MS_WORD,
                     'application/vnd.openxmlformats-officedocument.wordprocessingml.document' => :MS_WORD,
                     'application/excel' => :MS_EXCEL,
                     'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' => :MS_EXCEL,
                     'application/vnd.ms-excel' => :MS_EXCEL,
                     'application/vnd.oasis.opendocument.text' => :ODF_WRITER,
                     'application/vnd.oasis.opendocument.spreadsheet' => :ODF_CALC,
                     'image/jpeg' => :JPG
  }


## all pages per folder
#scope :per_folder, lambda { |fid|
#  joins("LEFT OUTER JOIN `documents` ON `documents`.`id` = `pages`.`document_id`").joins("LEFT OUTER JOIN folders ON folders.id = documents.folder_id").where("documents.folder_id=#{fid}")
# }

## all pages without  cover
  scope :per_folder_no_cover, lambda { |fid|
    joins(:document).where("cover_id is null and folder_id=#{fid} and pages.status=#{Page::UPLOADED_PROCESSED}")
  }

  scope :per_folder_with_cover, lambda { |fid|
    joins(:document).where("cover_id is not null and folder_id=#{fid} and pages.status=#{Page::UPLOADED_PROCESSED}")
  }


## all pages per cover
  scope :per_cover, lambda { |cid|
    joins("LEFT OUTER JOIN documents ON documents.id = pages.document_id").joins("LEFT OUTER JOIN covers ON covers.id = documents.cover_id").where("documents.cover_id=#{cid}")
  }

### Thinking Sphinx - index is on document, to trigger delta-index on page change - the delta flag is set for the document
  after_commit :set_delta_flag

  def set_delta_flag

    unless self.document.nil? or not Document.exists?(self.document.id)
      self.document.reload
      self.document.update_attribute(:delta, true)
    end
  end

########################################################################################################
### this page is displayed first in search results with all pages that have been removed from document
  def self.new_document_pages
    pages = Page.search("", Page.get_search_config(1, :relevance).merge!({:with => {:document_status => Document::DOCUMENT_FROM_PAGE_REMOVED}}))
  end

########################################################################################################

  def folder
    return nil if self.document.nil?
    return self.org_folder unless self.org_folder_id.nil? or self.org_folder_id == 0 ## we have an orginal cover_id, normally for scanned documents
    return self.document.folder
  end

  def cover
    return nil if self.document.nil?
    return self.org_cover unless self.org_cover_id.nil? ## we have an orginal cover_id, normally for scanned documents
    return self.document.cover
  end


### check, if a PDF file for a page exists, can be as original or it was loaded later
  def pdf_path
    if self.mime_type == 'application/pdf'
      path(:org)
    else
      path(:pdf)
    end
  end


### thats a nightmare, I admit
  def pretty_filename(type)

    ## determine basename
    if source == Page::PAGE_SOURCE_UPLOADED
      fn = File.basename(original_filename)
    else
      if !self.document.comment.nil? and self.document.comment.length > 0
        fn = self.document.comment[0, 20].gsub(" ", "_").gsub('ä', 'a').gsub('ö', 'o').gsub('ü', 'u').chars.select(&:ascii_only?).join + "_" + (position + 1).to_s
      else
        fn = "docbox_d#{document.id}_p#{id}_#{created_at.strftime("%Y%m%d")}" + "_" + (position + 1).to_s
      end
    end

    ## determine extension
    if type == :pdf
      fn = fn + ".pdf"
    end

    if type == :org
      if calc_pdf_as_org?
        fn = fn + ".pdf"
      elsif source == Page::PAGE_SOURCE_UPLOADED
        fn = fn
      else
        fn = fn + ".jpg"
      end
    end

    return fn
  end

  def has_document?
    not self.document.nil?
  end

## to read PDF and so on as symbols

  def self.uploading_status(mode)
    result = case mode
             when :no_backup then
               Page.where('backup=false and document_id IS NOT NULL').count
             when :not_processed then
               Page.where("status < #{Page::UPLOADED_PROCESSED}").count
             when :not_converted then
               Page.where("status = #{Page::UPLOADED}").count
             when :processing then
               Page.where("status = #{Page::UPLOADED_PROCESSING}").count
             when :no_ocr then
               Page.where('ocr = false').count
             else
               'ERROR'
             end
  end

### prepare status information and return as hash
  def self.status_hash
    res = Hash.new
      res[:upload] = Page.uploaded_pages.count.to_s
      res[:convert] = Page.uploading_status(:not_converted).to_s
      res[:pending_backup] = Page.uploading_status(:no_backup).to_s
      res[:pending_ocr] = Page.uploading_status(:no_ocr).to_s

    puts "Status Summary:"+res.to_s
    return res
  end

  def document_pages_count
    return 0 unless self.has_document?
    self.document.page_count
  end

  def self.uploaded_pages
    self.where("document_id is null")
  end

  def self.for_batch_conversion
    self.where("status = #{Page::UPLOADED}").select('id').map { |x| x.id }
  end

  def destroy_with_file

    self.document.check_no_delete unless self.document.nil? #raise exception if document has no deletion flag

    position = self.position
    last_page = (self.document_pages_count == 1)

    Dir.glob(self.path(:all)) do |filename|
      File.delete(filename)
    end

    #### page just uploaded
    if self.document.nil?
      self.destroy
      return last_page
    end

    Document.transaction do

      ## if only one page is left and this is destroyed, destroy document
      if self.document_pages_count == 1 then
        self.document.destroy
      else
        document = self.document
        self.destroy
        ### Clean up the document and the remaining pages
        CleanPositionsOnRemove(document.id, position) ## update position of remaining pages
        document.update_after_page_change

      end
    end

    return last_page
    ## return true if this is the last page

  end

## remove from document and create a new document
  def move_to_new_document

    ## save all values
    position = self.position
    old_document = self.document

    Page.transaction do
      doc = Document.new(:status => Document::DOCUMENT_FROM_PAGE_REMOVED, :page_count => 1, :folder_id => old_document.folder_id)
      doc.save!
      self.document_id = doc.id
      self.position = 0
      self.save!
      CleanPositionsOnRemove(old_document.id, position)
      old_document.update_after_page_change

    end

  end

## add new page to a document
  def add_to_document(document, position = document.page_count - 1)

    self.transaction do

      old_document_id = self.document_id

      self.document_id = document.id
      self.position = position
      self.save!

      self.document.update_after_page_change

      Document.find(old_document_id).destroy unless old_document_id.nil?

    end

  end


  def preview?
    File.exist?(self.path(:s_jpg))
  end

  def update_status(status)
    self.update_attributes(:status => status)
  end

### clean all pages, that got stucked in upload processing, because converter daemon crashed. shall be called when converter daemon connects again
  def self.clean_pending
    Page.where(:status => Page::UPLOADED_PROCESSING).update_all(:status => Page::UPLOADED)
  end

  def status_text
    status = ''
    if self.source == Page::PAGE_SOURCE_MIGRATED
      status = "* Migrated Document stored in FID #{self.fid} *"
    elsif self.document.nil? or (self.document.cover.nil? and self.document.folder.cover_ind?) then
      status = 'No cover created yet'
    elsif not (self.document.folder.cover_ind?)
      status = 'Document is only stored electronically'
    else
      status = "Cover ##{self.document.cover.counter} in #{self.document.cover.created_at.strftime "%B %Y"}"
    end
    status = '| ' + status unless status == ''
    return status
  end


### convert a page into a jpg file

  def jpg_file
    tmp_jpg_file_root = File.join(Dir.tmpdir, "cd_#{self.id}")
    res = %x[pdfimages -l 1 -f 1 -j #{self.path(:org)} #{tmp_jpg_file_root}]

    ## pdfimages adds -000.jpg to the outfile in tmp_jpg_file or pbm if file was converted in with black and white option

    unless File.exist?(tmp_jpg_file_root + '-000.jpg')
      res = %x[convert #{tmp_jpg_file_root}-000.pbm #{tmp_jpg_file_root}-000.jpg]
    end

    return File.open(tmp_jpg_file_root + '-000.jpg')

  end

##### mime type is stored in database as long text application/pdf for example

# mime type of original stored document

  def short_mime_type
    Page::PAGE_MIME_TYPES[self.mime_type]
  end

# set of helper functions to check for converter processing, room for improvement

# Mobile app is "hiding" in filename, if scan should be processed as foto or letter in converter
# if processed as foto, the orginal document will be the JPG, and an additional PDF is added
# if processed as letter, the original document will be the PDF, same as for normal scanning

  def convert_as_foto?
    return false if original_filename.nil?
    original_filename.include? "foto"
  end

# data from scanner or from mobile, when taking with "letter" option will have PDF as orginal, and no additional PDF
  def calc_pdf_as_org?
    ((self.source == PAGE_SOURCE_SCANNED or self.source == PAGE_SOURCE_MIGRATED) or (self.source == PAGE_SOURCE_MOBILE and not convert_as_foto?))
  end

### if an original as JPG already exists and this is called a second time, the PDF will be stored
  def save_file(file_path, file_type)

    path = file_path.tempfile

    FileUtils.cp path, self.path(file_type)
    FileUtils.chmod "go=rr", self.path(file_type)
  end


#### updates files system with conversion results and updates database status
  def update_conversion(result_jpg, result_sjpg, result_orginal, result_txt)

    self.save_file(result_sjpg, :s_jpg) unless result_sjpg.nil? # small preview pic
    self.save_file(result_jpg, :jpg) unless result_jpg.nil? # medium preview pic
    self.save_file(result_orginal, :org) unless result_orginal.nil?

    self.status = Page::UPLOADED_PROCESSED

    ### pages scanned as JPG are converted to PDF
    if self.short_mime_type == :JPG then
      self.mime_type = PAGE_DEFAULT_SCAN_MIME_TYPE
    end

    if result_sjpg.nil? then
      self.preview = Page::PAGE_NO_PREVIEW
    else
      self.preview = Page::PAGE_PREVIEW
    end

    self.content = result_txt

    self.save!

  end

  private

  def CleanPositionsOnRemove(document_id, position)
    Page.where("document_id = #{document_id} and position > #{position}").update_all("position=position-1")
  end


end


