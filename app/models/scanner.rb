
require 'ServiceConnector'

class Scanner

  COLOR_MODE_ON=true
  COLOR_MODE_OFF=false

  extend ServiceConnector ##provides methods to connect to remote drb services

  def self.service_name
    "Scanner"
  end

  attr_accessor :current_device, :color

  def self.start_copy(scanner_name)
    if self.connected?
      self.get_drb.scanner_copy(scanner_name)
    else
      Log.write_error('ScannerWorker', 'Not connected to scanner (copy)')
    end

  end

  def self.start_scan(scanner_name,color)

    if self.connected?
      self.get_drb.scanner_start_scann(scanner_name,color)
    else
      Log.write_error('ScannerWorker', 'Not connected to scanner (scan)')
    end

  end

    def self.connected_devices
    if self.connected?
      self.get_drb.scanner_list_devices
    else
      Array.new
    end

  end


end