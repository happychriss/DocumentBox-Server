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
puts "****** Start avahi register***"
puts "Port:#{port} and Name:Docbox_#{env}"
$stdout.flush
DNSSD.register! "Docbox_#{env}", "_#{env}_docbox._tcp", nil, port
puts "****** Completed avahi register***"
$stdout.flush
sleep
