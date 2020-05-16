class ConvertedPageChannel < ApplicationCable::Channel
  def subscribed
    stream_from "converted_page_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
