class UploadUpdateChannel < ApplicationCable::Channel
  def subscribed
    stream_from "upload_update_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
