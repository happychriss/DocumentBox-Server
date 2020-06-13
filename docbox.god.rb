CDSERVER_ROOT="//home/docbox/DBServer"
CDDAEMON_ROOT="//home/docbox/DBDaemons"
CDSERVER_PID = "//tmp"
CDSERVER_LOG= "#{CDSERVER_ROOT}/log"
NGINX_ROOT="/usr/local/nginx/sbin" #config in /usr/local/nginx/conf/nginx.conf
THIN_ROOT="/usr/local/bin/thin"
THIN_CONFIG=File.join(CDSERVER_ROOT,"thin_nginx.yml")
SUBNET="192.168.1"


God.watch do |w|
  w.name          = "sphinx"
  w.group         ='docbox'
  w.start_grace   = 10.seconds
  w.restart_grace = 10.seconds
  w.interval      = 60.seconds
  w.dir           = CDSERVER_ROOT
  w.env 	  = {'RAILS_ENV' => "production" }
  w.start         = "rake ts:start"
  w.stop          = "rake ts:stop"
  w.restart       = "rake ts:restart"
  w.pid_file      = "//tmp/sphinx.pid"
  w.keepalive
end

God.watch do |w|
  w.name          = 'sidekiq'
  w.group         = 'docbox'
  w.start_grace   = 10.seconds
  w.restart_grace = 10.seconds
  w.stop_grace    = 10.seconds
  w.interval      = 60.seconds
  w.dir           = CDSERVER_ROOT
  w.start         = "bundle exec sidekiq -e production -c 3 -P #{CDSERVER_PID}/sidekiq.pid"
  w.stop          = "bundle exec sidekiqctl stop #{CDSERVER_PID}/sidekiq.pid 5"
  w.keepalive
  w.log           = File.join(CDSERVER_LOG, 'sidekiq.log')
  w.behavior(:clean_pid_file)
#  w.env           = {'HOME' => '/root'} ## for gpg
end
God.watch do |w|
  w.name          = 'clockwork'
  w.group         = 'docbox'
  w.start_grace   = 10.seconds
  w.restart_grace = 10.seconds
  w.stop_grace    = 10.seconds
  w.interval      = 60.seconds
  w.dir           = CDSERVER_ROOT
  w.start         = "bundle exec clockwork ./services/cdserver_maintenance_job.rb & echo $! > #{CDSERVER_PID}/clockwork.pid"
  w.stop          = "kill -QUIT `cat #{CDSERVER_PID}/clockwork.pid`"
  w.keepalive
  w.log           = File.join(CDSERVER_LOG, 'clockwork.log')
  w.behavior(:clean_pid_file)
  w.env           = {'RAILS_ENV' => "production" }
  w.pid_file      = "#{CDSERVER_PID}/clockwork.pid"
end

#God.watch do |w|
#  w.name          = "unicorn"
#  w.group         = "docbox"
#  w.dir           = CDSERVER_ROOT
#  w.start_grace   = 10.seconds
#  w.restart_grace = 10.seconds
#  w.interval      = 60.seconds
#  w.start         = "bundle exec unicorn -c /home/docbox/DBServer/unicorn.conf.rb"
#  w.pid_file      = "//tmp/unicorn.pid" 
#  w.log           = "#{CDSERVER_LOG}/unicorn.log"  
#  w.stop_signal   = 'QUIT'
#  w.keepalive
#end

#avahi daemon to register the converter and scanner
God.watch do |w|
  w.name 	  = "avahi"  
  w.group         ='docbox'
  w.dir           = CDSERVER_ROOT  
  w.start 	  = "bundle exec ruby #{CDSERVER_ROOT}/services/avahi_service_start_port.rb -p 8082 -e production"
  w.log           = "#{CDSERVER_LOG}/avahi.log"  
  w.keepalive
end

################# Not part of CDServer #########################################################################
#scanner server, in case scanner is connected with cubietrack
God.watch do |w|
  w.start_grace   = 10.seconds
  w.env           = {'BUNDLE_GEMFILE' => '//home/docbox/DBDaemons/Gemfile'}
  w.name 	  ='scanner_daemon'
  w.group         ='docbox'
  w.dir           = CDDAEMON_ROOT
  w.start         = "bundle exec ruby #{CDDAEMON_ROOT}/cdclient_daemon.rb --service Scanner --uid 101 --prio 1 --subnet #{SUBNET} --port 8971 --avahiprefix production --unpaper_speed y"
  w.log           = "#{CDDAEMON_ROOT}/cdscanner.log"  
  w.keepalive
end

#
#God.watch do |w|
#  w.start_grace   = 10.seconds
#  w.env           = {'BUNDLE_GEMFILE' => '//home/docbox/DBDaemons/Gemfile'}
#  w.name 	  ='hardware_daemon'
#  w.group         ='docbox'
#  w.dir           = CDDAEMON_ROOT
#  w.start         = "bundle exec ruby #{CDDAEMON_ROOT}/cdclient_daemon.rb --service Hardware --uid 102 --prio 0 --subnet #{SUBNET} --port 8972 --avahiprefix production --gpio_server pi --gpio_port 8780"
#  w.log           = "#{CDDAEMON_ROOT}/cdhardware.log"
#  w.keepalive
#end

God.watch do |w|
  w.start_grace   = 10.seconds
  w.env           = {'BUNDLE_GEMFILE' => '//home/docbox/DBDaemons/Gemfile'}
  w.name 	  ='converter_daemon'
  w.group         ='docbox'
  w.dir           = CDDAEMON_ROOT
  w.start         = "bundle exec ruby #{CDDAEMON_ROOT}/cdclient_daemon.rb --service Converter --uid 103 --prio 0 --subnet #{SUBNET} --port 8973 --avahiprefix production"
  w.log           = "#{CDDAEMON_ROOT}/cdconverter.log"
  w.keepalive
end

#touchswitch tst server
#God.watch do |w|
#  w.start_grace   = 10.seconds
#  w.env           = {'BUNDLE_GEMFILE' => '//home/docbox/DBServer/Gemfile'}
#  w.name 	  ='touchswitch_server'
#  w.group         ='docbox'
#  w.dir           = CDSERVER_ROOT
#  w.start         = "bundle exec ruby #{CDSERVER_ROOT}/tst.rb"
#  w.log           = "#{CDSERVER_LOG}/tst.log"
#  w.keepalive
#end

