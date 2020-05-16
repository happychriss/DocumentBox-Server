class AppStatusChannel < ApplicationCable::Channel
  def subscribed
    stream_from "app_status_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
