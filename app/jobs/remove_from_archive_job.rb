class RemoveFromArchiveJob < ActiveJob::Base
  queue_as :default

  require "fileutils"
  require 'SecretManager'
  include SecretManager

  def perform

    begin

      ThinkingSphinx::Deltas.suspend(:document) do

        docs = Document.where("delete_at is not null and delete_at < ?", Date.today) ### be carefuls with this line !!!!1

        unless docs.count.nil? then

          s3 = Aws::S3::Resource.new(
              credentials: Aws::Credentials.new(aws_s3_key, aws_s3_secret),
              region: aws_region
          )

          docs.each do |doc|

            doc.check_no_delete #raise exception if document should not be deleted

            Document.transaction do

              doc.pages.each do |page|

                obj = s3.bucket(aws_s3_bucket).object(page.file_name(:gpg))
                if obj.exists?
                obj.delete
                else
                  raise "Object: #{page.file_name(:gpg)} does not exists in bucket: #{aws_s3_bucket}"
                end


                ## remove from file system
                Dir.glob(page.path(:all)) do |filename|
                  File.delete(filename)
                end

              end

              doc_summary = "ID: #{doc.id} - #{doc.comment} archived until #{doc.delete_at.strftime('%B %Y')}  with #{doc.pages.count} pages"

              doc.destroy

              ## remove from DB
              Log.write_status('ArchiveClean', 'Deleted: ' + doc_summary)
            end
          end
        end
      end
    rescue Exception => e
      Log.write_error('ArchiveClean', 'Delete: ' + '->' + e.message)
      raise
    ensure
      SphinxIndexWorker.perform_async
    end
  end
end