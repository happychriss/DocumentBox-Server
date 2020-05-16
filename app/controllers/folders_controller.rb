class FoldersController < ApplicationController
  before_action :accept_all_params
  # GET /folders
  # GET /folders.json
  # called from CDClient to get list of folders available
  def index
    @folders = Folder.all

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @folder }
    end

  end

  def show
    @folder = Folder.find(params[:id])
  end

  def new
    @folder = Folder.new
  end


  def edit
    @folder = Folder.find(params[:id])
  end

  def create
    @folder = Folder.new(params[:folder])

    respond_to do |format|
      if @folder.save
        redirect_to :action => 'index'
        return true
      else
        render action: "new"
      end
    end
  end

  def update
    @folder = Folder.find(params[:id])

    respond_to do |format|
      if @folder.update_attributes(params[:folder])
        redirect_to :action => 'index'
        return true
      else
        render action: "edit"

      end
    end
  end

  def destroy
    @folder = Folder.find(params[:id])
    @folder.destroy
    redirect_to folders_url

  end


  def accept_all_params
    params.permit!
  end

end
