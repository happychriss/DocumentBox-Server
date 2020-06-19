class SphinxReindexJob < ActiveJob::Base
  require "SphinxRakeSupport"

    def perform
      Rails.logger.info "### Sphinx - Start Index"
      SphinxRakeSupport::Schedule.ts_index
      Rails.logger.info "### Sphinx - Index Completed"
      Log.write_status("SphinxIndex", "*********** Completed Sphinx-Reindex **************")
    end

end