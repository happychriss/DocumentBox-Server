class Document < ActiveRecord::Base

  require 'tempfile'

  ThinkingSphinx::Callbacks.append(
      self, :behaviours => [:sql, :deltas]
  )


  has_many :pages, -> { order :position }, dependent: :destroy
  belongs_to :folder, optional: true
  belongs_to :cover, optional: true
  has_one :pinned_document,  dependent: :destroy


  accepts_nested_attributes_for :pages, :allow_destroy => true
  acts_as_taggable_on :keywords

  before_save :update_expiration_date
  before_destroy :check_no_delete

  #### Status
  DOCUMENT = 0 ##document was created based on an uploaded document
  DOCUMENT_FROM_PAGE_REMOVED = 1 ##document was created, as a page was removed from an existing doc
  DOCUMENT_NOT_ARCHIVED = 2


  ########################################################################################################

  def self.search_index(search_string, keywords, page_no, sort_mode)
    ###https://groups.google.com/forum/?fromgroups=#!msg/thinking-sphinx/WvOTN6NABN0/vzKnhx5CIvAJ

    search_config = {:page => page_no, :per_page => 30, :star => true}

    search_config.merge!({:with => {:tags => keywords.map! { |e| e.to_i }}}) unless keywords.empty?
    search_config.merge!({:order => "created_at desc, id DESC"}) if sort_mode == :time

    documents = Document.search(search_string, search_config)

    Rails.logger.info  "Document ******************************************"
    Rails.logger.info  "SearchConfig: #{search_config}"
    Rails.logger.info  "SearchString: #{search_string}"
    Rails.logger.info  "***************************************************"

    return documents

  end

  def cover_page
    self.pages.where(position: 0).first
  end


  def pdf_file

    docs = ''; self.pages.each { |p| docs += ' ' + p.pdf_path }
    pdf = Tempfile.new(["cd_#{self.id}", ".pdf"])

    #  if pdftk is not available for OS, you can use java_itext instead
    #  java_merge_pdf = "java -classpath './SupportFiles/java_itext/.:./java_itext/itext-5.3.5/*' MergePDF"   # java itext

    java_merge_pdf = "pdftk #{docs} cat output #{pdf.path}"
    Rails.logger.info  "PDF_FILE, merging PDF with pdftk and command: #{java_merge_pdf}"
    res = %x[#{java_merge_pdf}]
    return pdf
  end

  def backup?
    self.pages.where("backup = 0").count == 0
  end

  def pinned?
    self .pinned_document.present?
  end

  def removed?
    self.status==Document::DOCUMENT_FROM_PAGE_REMOVED
  end

  def update_after_page_change
    self.page_count = self.pages.count

    if self.page_count == 0
      self.destroy
    else

      ### if documents has pages with non-pdf-mime type, no complete PDF page can be generated
      if self.pages.where("pdf_exists=false").count > 0
        self.complete_pdf = false
      else
        self.complete_pdf = true
      end

      self.save!
    end
  end


  def check_no_delete
    if self.no_delete?
      Log.write_error('MAJOR ERROR', "System tried to delete -NO_DELETE- document with id:#{self.id}")
      raise "ERROR: System tried to delete -NO_DELETE- document with id:#{self.id}"
    end
  end

  # a summary page can only be displayed
  def show_summary_page?
    return true if (self.no_complete_pdf == false or self.page_count == 1)
    return false
  end

  def pretty_filename
    if cover_page.source == Page::PAGE_SOURCE_UPLOADED
      File.basename(cover_page.original_filename) + ".pdf"
    elsif comment.length > 0
      comment[0, 20].gsub(" ", "_").gsub('ä', 'a').gsub('ö', 'o').gsub('ü', 'u').chars.select(&:ascii_only?).join + ".pdf"
    else
      "docbox_d#{id}_p#{cover_page.id}_#{created_at.strftime("%Y%m%d")}" + ".pdf"
    end

  end

  private

  ##http://stackoverflow.com/questions/4902804/using-delta-indexes-for-associations-in-thinking-sphinx



  def update_expiration_date
    self.delete_at = nil if self.delete_at == Date.new(3000) #to allow reset the date back to null (newer expire)
  end

  ### https://github.com/mperham/sidekiq/blob/master/examples/clockwork.rb


end
