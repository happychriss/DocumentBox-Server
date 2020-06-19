class BackupDbJob < ActiveJob::Base
  queue_as :default
  require 'tmpdir'
  require 'Pusher'
  require 'SecretManager'
  require 'aws-sdk-s3'
  include SecretManager
  include Pusher
  include ActionView::Helpers::UrlHelper

  DB_BACKUP_FOLDER= "//data/docstore_db"


  def perform
    info_text=""
    begin

      puts "*************************** Starting Database backup with pg_dump"

      ### Step-1: Create DB Backup
      db_dump_file="db_backup_docbox_#{Rails.env}_"+Time.now.strftime("%Y%m%d_%H%M_%S")
      db_dump_file=File.join(DB_BACKUP_FOLDER,db_dump_file)
      puts "Step-1: Create DB Backup:"
      shell_exec("PG_DUMP", "pg_dump --dbname=docbox_#{Rails.env} --username=#{db_postgres_user} --format=custom  --file=#{db_dump_file}")

      ### Step-2: Encrypt File
      pgp_file=db_dump_file+".gpg"
      puts "Step-2: Encrypt File"
      shell_exec("PGP", "gpg -q --no-verbose --yes -a -o #{pgp_file} -r " + aws_gpg_email_address + " -e #{db_dump_file}")

      ### Step-3: Upload to S3
      puts "Step-2: Upload to S3"

      s3 = Aws::S3::Resource.new(
          credentials: Aws::Credentials.new(aws_s3_key, aws_s3_secret),
          region:aws_region
      )

      obj=s3.bucket(aws_s3_db_bucket).object(File.basename(pgp_file))
      info_text="S3 Upload to #{aws_s3_db_bucket}"
      obj.upload_file(pgp_file)

      ### Step-4: Clean Up
      File.delete(pgp_file)

      puts "Upload to bucket: #{aws_s3_db_bucket} done!"
      Log.write_status('BackupJob', "Backup completed to #{aws_s3_db_bucket}")

    end
  rescue Exception => e
    Log.write_error('BackupJob', info_text + '->' +e.message)
    push_app_status ## send status-update to application main page via private_pub gem, fayes,
#    raise
  end


end

private

def shell_exec(step,command)
  puts "ShellExec[#{step}]: #{command}"
  Open3.popen3(command) do |stdin, stdout, stderr, thread|
    err_txt=stderr.read.chomp
    unless err_txt==""
      puts "ERROR: #{err_txt}"
      raise "Shell-Exec - error on "+step+":"+ err_txt
    end
  end
end
