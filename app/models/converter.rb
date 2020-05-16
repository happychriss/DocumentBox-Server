require 'ServiceConnector'

class Converter

  CONV_FLAG_PDF_AS_ORG = 1
  CONV_FLAG_AS_LETTER = 2

  extend ServiceConnector ##provides methods to connect to remote drb services

  def self.service_name
    "Converter"
  end


  def self.run_pdf_creation(document_id)

    document=Document.find(document_id)

    if Converter.connected? then
      puts "Start remote call: Processing PDF convertion file remote: #{document.id} with  #{document.pages.count} pages"

    end
  end

  def self.run_conversion(page_ids)

    page_ids.each do |page_id|

      page=Page.find(page_id)

      if Converter.connected? then

        page.update_status(Page::UPLOADED_PROCESSING)

        puts "Start remote call: Processing scanned file remote: #{page.id} with path: #{page.path(:org)} and mime type #{page.short_mime_type} and Source: #{page.source.to_s}"

        scanned_jpg=File.read(page.path(:org))

        ### REMOTE CALL via DRB - the server can run on any server: distributed ruby

        ## Determine converter flags
        converter_flags=0
        converter_flags=converter_flags+CONV_FLAG_AS_LETTER unless page.convert_as_foto?
        converter_flags=converter_flags+CONV_FLAG_PDF_AS_ORG if page.calc_pdf_as_org?
        puts "Converter-Flags:"+ converter_flags.to_s


        Converter.get_drb.run_conversion(scanned_jpg,page.short_mime_type, converter_flags, page.id)

        puts "Completed remote call to DRB"

      else

        puts "NO DRB found for #{page.id} , updating as not processed"

      end

    end

  end
end