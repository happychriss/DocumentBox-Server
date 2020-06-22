require 'socket'

class TouchSwitch

  def self.service_name
    "TouchSwitch"
  end

  def self.connect(connection_uri)
    Rails.logger.info  "**** Daemon - Request: Create/Find connection for *Touchswitch* and uri:#{connection_uri}"
    connection = Connector.where(uid: connection_uri[:uid]).first
    
    if connection.nil?
	    connection = Connector.new(connection_uri)
    else
            connection.update_attributes(connection_uri)
    end

    connection.save!
  end


## will only send the message to the touchswich, that the feeder return, so it can start again
  def self.send_status(message, scan_complete = false)


    if scan_complete and (message.include? "Feeder" or message.include? "Warning" or message.include? "Error" or message.include? "SIMULAT")
#    if (true)

      tw = Connector.find_by service: TouchSwitch.service_name

      unless tw.nil?

        tw_uri = URI.parse("http://" + tw.uri)

        begin
          sleep 1
          TCPSocket.open(tw_uri.host, tw_uri.port) { |s| s.puts message + "\n"; sleep 0.5 }

        rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
          Rails.logger.info  "**** Touchswitch not reachable as #{tw_uri.host}:#{tw_uri.port.to_s}"
        rescue => e
          Rails.logger.info  "************ ERROR *****: #{e.message}"
          raise
        end
      end


    end

  end

end
