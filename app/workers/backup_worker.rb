class BackupWorker
  require 'tmpdir'
 require 'Pusher'
  require 'SecretManager'
  include Sidekiq::Worker
  include SecretManager
  include Pusher
  include ActionView::Helpers::UrlHelper

  sidekiq_options :retry => false

  ## Backup for all documents in status "0" with pages in status "uploaded and processed"
  # we dont want to update pages that are homeless (status from page removed or PDF only)
  def perform(document_id=nil)

    begin

      info_text=''

      # create a connection
       gpg_email=Array.new(1, aws_gpg_email_address)
      # connection= AWS::S3::Base.establish_connection!(:access_key_id => aws_s3_key, :secret_access_key => aws_s3_secret)

      if document_id.nil? then
         #only in status "0" docs should be sent to backup - can be done in
        backup_pages=Page.where(backup:false,status:Page::UPLOADED_PROCESSED,document_id: Document.select(:id).where(status:Document::DOCUMENT) )
#        backup_pages=Page.where("backup = 0 and status=#{Page::UPLOADED_PROCESSED}")
        logger.info "### LOAD DAEMON:---Start Uploading for pages without backup, count: #{backup_pages.count} pages ------------"
      else
        doc=Document.where(status:Document::DOCUMENT,id:document_id)
        logger.info "### LOAD DAEMON:---Start Uploading for document #{doc.id} with #{doc.page_count} pages ------------"
        backup_pages=doc.pages
      end

      backup_pages.each do |page|

        if page.backup==false and page.status==Page::UPLOADED_PROCESSED then

          push_app_status ## send status-update to application main page via private_pub gem, fayes,

          source_name=page.path(:org)
          pgp_name=File.join(Dir.tmpdir, page.file_name(:gpg))

          ####### Debugging
          info_text=" page_id: #{page.id} doc_id: #{page.document.id} pgp_name: #{pgp_name} AmazonBucket: #{aws_s3_bucket}"

          #### Encrypt file
          # gpg_home_dir=Rails.root.join('.gnupg').to_s ##used in previous version, not sure why
          command = "gpg -q --no-verbose --yes -a -o #{pgp_name} -r " + aws_gpg_email_address + " -e #{source_name}"
          res=%x[#{command}]
	  res2=%x[whoami]
   	  logger.info "GPG executed with command: #{command} res: #{res} for user: #{res2}"

          logger.info "### LOAD DAEMON:---Start Uploading page: #{page.id} to S3 #{aws_s3_bucket}------------"
          result=AWS::S3::S3Object.store(File.basename(pgp_name), open(pgp_name), aws_s3_bucket)
          File.delete(pgp_name);
          page.update_attribute('backup', true)

          push_app_status ## send status-update to application main page via private_pub gem, fayes,

          Log.write_status('backup', "backup completed for page_id #{page.id} doc_id #{page.document.id} to Amazon #{aws_s3_bucket} with #{pgp_name}")

        end

      end
    end
  rescue Exception => e
    Log.write_error('BackupWorker', info_text + '->' +e.message)
    push_app_status ## send status-update to application main page via private_pub gem, fayes,
    raise
  end


end

