require "fileutils"
require 'SecretManager'
include Sidekiq::Worker
include SecretManager

class RemoveFromArchiveWorker

  def perform

    begin

      ThinkingSphinx.deltas_enabled = false

      docs=Document.where("delete_at is not null and delete_at < ?", Date.today) ### be carefuls with this line !!!!1

      unless docs.count.nil? then

        connection= AWS::S3::Base.establish_connection!(:access_key_id => aws_s3_key, :secret_access_key => aws_s3_secret)

        docs.each do |doc|

          doc.check_no_delete #raise exception if document should not be deleted

          Document.transaction do

            doc.pages.each do |page|

              ## remove from S3
              result=AWS::S3::S3Object.delete(page.file_name(:gpg), aws_s3_bucket)

              ## remove from file system
              Dir.glob(page.path(:all)) do |filename|
                File.delete(filename)
              end

            end

            doc_summary="ID: #{doc.id} - #{doc.comment} archived until #{doc.delete_at.strftime('%B %Y')}  with #{doc.pages.count} pages"

            doc.destroy

            ## remove from DB
            Log.write_status('ArchiveClean','Deleted: '+doc_summary )
          end
        end
      end
    end
  rescue Exception => e
    Log.write_error('ArchiveClean', 'Delete: ' + '->' +e.message)
    raise
  ensure
    ThinkingSphinx.deltas_enabled = true
    SphinxIndexWorker.perform_async
    end
end