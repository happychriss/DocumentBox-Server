# Sidekiq defers scheduling to other, better suited gems.
# If you want to run a job regularly, here's an example
# of using the 'clockwork' gem to push jobs to Sidekiq
# regularly.

# require boot & environment for a Rails app

# require_relative "../config/boot"
require_relative "../config/environment"
require "SphinxRakeSupport"
require "clockwork"


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
#  every(2.minute, 'BackupJob.perform') do
    BackupDbJob.perform_later
  end

#  every(1.week, 'SphinxIndexWorker.perform_async', :at => '19:30') do
  every(4.minute, 'SphinxIndexWorker.perform_async', :at => '19:30') do
    SphinxIndexWorker.perform
  end

 # every(1.month, 'RemoveFromArchiveJob.perform_async') do
 #   RemoveFromArchiveJob.perform_async
 # end
end
