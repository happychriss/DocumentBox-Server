require 'ServiceConnector'

class Hardware

  extend ServiceConnector ##provides methods to connect to remote drb services

  def self.service_name
    "Hardware"
  end

  def self.set_ok_status_led(value)      #:on or :off
    self.get_drb.set_ok_status_led(value) if self.connected?
  end

  def self.set_yellow_status_led(value)
    self.get_drb.set_yellow_status_led(value) if self.connected?
  end


  def self.blink_ok_status_led
    self.get_drb.blink_ok_status_led if self.connected?
  end

  def self.blink_yellow_status_led
    self.get_drb.blink_yellow_status_led if self.connected?
  end


  def self.watch_scanner_button_on
    self.get_drb.watch_scanner_start_button if self.connected?
  end

  def self.update_status_leds
    self.get_drb.update_status_leds if self.connected?
  end
end