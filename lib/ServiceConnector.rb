## included by models that are implemented as remote objects
# it is  working in 3 steps
# 1) check if a valid connection exists in the @@drb_connection (class variable)
# 2) if not it will create a connection based in the database connection
# The remote daemon is calling connection.create / connection.delete to announce the status
# The remote daemon is listening to avahi-server running as initializer (avahi_anounce), if he sees a server to respond
# he will trigger a post call to create the connection

require 'drb/drb'

module ServiceConnector



  def connect(connection_uri)

   Rails.logger.info( "**** Daemon - Request: Create/Find connection for #{self.service_name} and uri:#{connection_uri}")
    connection = Connector.find_or_initialize_by uid: connection_uri[:uid]
    connection_uri.permit!
    connection.update(connection_uri)
    connection.save!
    get_drb
  end


  ### check if a working DRB connection exsits

  def connected?


    Rails.logger.info "Checking for connection for service:#{self.service_name}"
    begin
      drb=get_drb
      if drb.nil? then
        return false
      else
        return true
      end

    rescue
      return false
    end

  end



  ### return a DRB connection either from DB or from DRB connection object
  def get_drb

    begin
      Rails.logger.info "************* Request DRB Connection for service: #{self.service_name}"

      ##http://dalibornasevic.com/posts/9-ruby-singleton-pattern  class variables as singelton
      @@drb_connections||=Hash.new

      ## check if service is registered in DB

      connection=Connector.find_service(self.service_name)

      if connection.nil? then
        Rails.logger.info "No connection found in DB - return nil"
        return nil
      end

      ## check of the DRB object still works, if not remove the DRB object
      drb=@@drb_connections[connection.uid]
      if !drb.nil? and drb_connected?(drb) then
        Rails.logger.info "*** Found working DRB connection in the HASH  - OK"
        return drb
      end

      ### create a new connection from the database

      Rails.logger.info "Found a not working DRB connection , try to create new one with uri: #{connection.uri}"
      @@drb_connections.delete(connection.uid)

      drb= DRb::DRbObject.new_with_uri(connection.uri) ##

      if drb_connected?(drb) then
        Rails.logger.info "**** Connection established"
        @@drb_connections[connection.uid]=drb
        return drb
      else
        Rails.logger.info "***** ERROR -  connection not established: #{@@drb_connections.inspect}**********"
        connection.destroy
        return nil
        raise "Connection in DB not vaild anymore - connection deleted for uri #{connection.uri}"
      end


    rescue Exception => e
      Rails.logger.info("ERROR: #{Time.now} DRBConnection - ServiceConnector" + e.message)
      raise
    end

  end


  private

  def drb_connected?(drb)
    connected=false
    begin
      connected=drb.alive?
    rescue DRb::DRbConnError
      connected=false
    end
    return connected
  end
end

