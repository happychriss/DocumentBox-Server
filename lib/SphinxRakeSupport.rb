module SphinxRakeSupport

  class Schedule

    def self.ts_start
      call_rake('ts:start')
    end

    def self.ts_index
      call_rake('ts:index')
    end

    def self.call_rake(task, options = {})
      options[:rails_env] ||= Rails.env
      args = options.map { |n, v| "#{n.to_s.upcase}='#{v}'" }
      system "rake -f #{Rails.root}/Rakefile #{task} #{args.join(' ')}  --silent --trace 2>&1 >> #{Rails.root}/log/rake.log "
    end

  end

end
