class ScannerUpdateChannel < ApplicationCable::Channel
  def subscribed
    stream_from "scanner_update_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
