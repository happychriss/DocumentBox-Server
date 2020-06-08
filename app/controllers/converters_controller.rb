require 'Pusher'

class ConvertersController < ApplicationController
  include Pusher
  before_action :accept_all_params
  skip_before_action :verify_authenticity_token


  def accept_all_params
    params.permit!
  end

end
