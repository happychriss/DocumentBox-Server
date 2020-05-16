class CoversController < ApplicationController
  before_action :accept_all_params

  def index
    @covers = Cover.order('id desc')
  end

  # GET /covers/1
  # GET /covers/1.json
  # Called by CDClient to read the PDF
  def show
    @cover = Cover.find(params[:id])

    respond_to do |format|
      format.html { send_file(@cover.build_pdf, :type => 'application/pdf', :page => '1') }

      ### returns pdf for the client
      format.json { send_file(@cover.build_pdf, :type => 'application/pdf', :page => '1') }
    end
  end

  def new
    @cover = Cover.new
  end


  # POST /covers
  # POST /covers.json
  # callled by CDclient to create a new cover

  def create

    folder_id=params[:cover][:folder_id]

    @cover=Cover.new_for_folder(folder_id)

    respond_to do |format|
      if @cover.nil? then
        @cover=Cover.new
        format.html { redirect_to @cover, notice: 'No pages found for cover' }
        format.json { render json: @cover, status: :created, location: @cover }
      elsif @cover.save
        format.html { send_file(@cover.build_pdf, :type => 'application/pdf', :page => '1') }
        format.json { render json: @cover, status: :created, location: @cover }
      else
        format.html { render action: "new" }
        format.json { render json: @cover.errors, status: :unprocessable_entity }
      end
    end

  end

  def update
    @cover = Cover.find(params[:id])

    if @cover.update_attributes(params[:cover])
      redirect_to @cover, notice: 'Cover was successfully updated.'
    else
      render action: "edit"
    end

  end

  def destroy
    @cover = Cover.find(params[:id])
    @cover.destroy

    redirect_to covers_url
  end

  ############# non standard action

  def show_cover_pages

    f=params[:id]
    unless f.nil?

      @folder=Folder.find(params[:id])

      @page_count=Page.per_folder_no_cover(@folder.id).count
      @pages=Page.per_folder_no_cover(@folder.id).limit(20)
    end

  end

  def accept_all_params
    params.permit!
  end

end
