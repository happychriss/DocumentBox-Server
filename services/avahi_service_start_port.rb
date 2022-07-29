require 'dnssd'

Signal.trap("INT") do
  puts "\nTerminated"
$stdout.flush
  exit
end

port=0;env=''
 ARGV.each_with_index do|a,i|
          port=ARGV[i+1].to_i if a=='-p'
	  env =ARGV[i+1]      if a=='-e'

end
puts "****** Start avahi register v2***"
puts "Port:#{port} and Name:Docbox_#{env}"
$stdout.flush
service=DNSSD.register "Docbox_#{env}", "_#{env}_docbox._tcp", nil, port
if service.started?
  puts "****** Completed avahi register***"
else
  puts "****** ERROR: Registering avahi-service"
end

$stdout.flush
sleep
