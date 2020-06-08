class Cover < ActiveRecord::Base

  require 'prawn'

  ### Changed for GIT

  has_many :documents
  belongs_to :folder

  before_destroy :update_pages

  ### scanned document page size
  PAGE_WITH=130
  PAGE_HEIGHT=200

#  X_MAX = Prawn::Document::PageGeometry::SIZES["A4"][0]-100
#   Y_MAX = Prawn::Document::PageGeometry::SIZES["A4"][1]

  X_MAX = 595.28-100
  Y_MAX = 841.89

  X_MIDDLE=X_MAX/2
  Y_MIDDLE=Y_MAX/2-35

  BOTTOM_SPACE=150 #for folder line


  def bottom_page(pdf)
    pdf.move_cursor_to BOTTOM_SPACE
    pdf.stroke_horizontal_rule
    pdf.fill_circle [X_MIDDLE, BOTTOM_SPACE], 10
  end


  def build_pdf

    tmp_file=File.join(Dir.tmpdir, "#{self.id}.pdf")

    y_max_pics=BOTTOM_SPACE ##y=0 is bottom of page

    pages=Page.per_cover(self.id).order('id asc')

    my_pdf=Prawn::Document.generate(tmp_file, :page_size => 'A4') do |pdf|

      page_no=1

      cover_line= "Cover: #{self.counter}     Folder:#{self.folder.short_name}       "
      cover_line+="Created: #{self.created_at.strftime('%d.%m.%y')}       "
      cover_line+="Page: #{page_no}"
      pdf.text cover_line

      pdf.stroke_horizontal_rule

      x=0
      y=pdf.cursor-20

      pages.each do |page|
        pdf.image page.path(:s_jpg), :width => PAGE_WITH, :at => [x, y]
        pdf.draw_text "*#{self.counter} - #{page.fid}*  (ID#{page.id})", :at => [x, y], :size => 8 ### page cover line

        x=x+PAGE_WITH
        if x>X_MAX then ## new row
          y=y-PAGE_HEIGHT
          x=0

          if y<y_max_pics then # new page

            bottom_page(pdf) if page_no==1

            page_no=page_no+1

            pdf.start_new_page
            pdf.text "Page: #{page_no}"
            pdf.stroke_horizontal_rule
            pdf.fill_circle [0, Y_MIDDLE], 10 ###other sides could by portrait format also

            y=pdf.cursor-20
            y_max_pics=5
          end

        end ## end of new roe

        bottom_page(pdf) if page_no==1

      end ## of pages loop

    end

    return tmp_file
  end


  def self.new_for_folder(folder_id)

    f=Folder.find(folder_id)
    retun nil unless f.cover_ind?

    cover=nil

    self.transaction do

      pages_no_cover=Page.per_folder_no_cover(folder_id).all

      if pages_no_cover.count>0 then

        # Create new cover
        cover = Cover.new
        cover.folder_id=folder_id
        cover.counter=(Cover.where(:folder_id => folder_id).maximum('counter').to_i)+1
        cover.save!
        cover.reload

        # up pages
        ## needs to be done in two steps, as join with order and update does not work in rails
        # pages must be updated before documents!!!!

        update_pages=pages_no_cover.collect { |p| p.id }.join(",")
        pages_with_cover=Page.per_folder_with_cover(folder_id);


        if pages_with_cover.count>0 then
          ## migrating to postgres, has a different order for null values
          max_fid=Page.per_folder_with_cover(folder_id).order('fid desc nulls last').first.fid
        else
          max_fid=1
        end

        self.connection.execute("SELECT SETVAL('pages_fid_seq', #{max_fid})") #https://kylewbanks.com/blog/Adding-or-Modifying-a-PostgreSQL-Sequence-Auto-Increment
#        self.connection.execute("\\set fid_count #{max_fid}") #http://stackoverflow.com/questions/6412186/rails-using-sql-variables-in-find-by-sql
        Page.where("id in (#{update_pages})").order("id asc").update_all("org_folder_id=#{folder_id},org_cover_id=#{cover.id},fid=nextval('pages_fid_seq')")

        # update documents (update, condition)
        Document.where("folder_id = #{folder_id} and cover_id is null").update_all("cover_id = #{cover.id}")
      end
    end

    return cover
  end

  private


### remove cover from all pages
  def update_pages
    self.pages.clear
  end


end
