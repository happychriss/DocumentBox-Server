# Sidekiq defers scheduling to other, better suited gems.
# If you want to run a job regularly, here's an example
# of using the 'clockwork' gem to push jobs to Sidekiq
# regularly.

# require boot & environment for a Rails app

# require_relative "../config/boot"
require_relative "../config/environment"
require "SphinxRakeSupport"
require "clockwork"


class DBBackupWorker

  def self.perform
    Rails.logger.info "### DBBackup - Start "
#    res=%x[backup perform --trigger=cd2_db_backup --config-file='#{Rails.root}/backup/config.rb']
    Bundler.with_clean_env do ##https://github.com/meskyanichi/backup/issues/306

      Rails.logger.info "** Environment: #{Rails.env}"

      res=%x[RAILS_ENV=#{Rails.env} backup perform --root-path='#{Rails.root}' --trigger=cd2_db_backup --config-file='./db_backup/config.rb' --log-path='./log' --quiet --data-path='./tmp']

      return_value=$?.exitstatus

      if return_value!=0 then
        Log.write_status("DB-Backup", "*********** ERROR in Backup ************** with result:#{return_value}")
        Rails.logger.info "### DBBackup - Stop with Error"
      else
        Log.write_status("DB-Backup", "*********** Completed Backup ************** with result:#{return_value}")
        Rails.logger.info "### DBBackup - Stop "
      end
    end
  end
end


class SphinxIndexWorker

  def self.perform
    Rails.logger.info "### Sphinx - Start Index"
    SphinxRakeSupport::Schedule.ts_index
    Rails.logger.info "### Sphinx - Index Completed"
    Log.write_status("SphinxIndex", "*********** Completed Sphinx-Reindex **************")
  end
end


module Clockwork
  every(1.week, 'BackupJob.perform_async', :at => '19:00') do
#  every(1.minute, 'BackupJob.perform') do
    DBBackupWorker.perform
  end

  every(1.week, 'SphinxIndexWorker.perform_async', :at => '19:30') do
    SphinxIndexWorker.perform
  end

 # every(1.month, 'RemoveFromArchiveJob.perform_async') do
 #   RemoveFromArchiveJob.perform_async
 # end
end
