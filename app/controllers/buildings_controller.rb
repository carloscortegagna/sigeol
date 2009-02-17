class BuildingsController < ApplicationController
  skip_before_filter :login_required, :only => :index

  # GET /buildings
  # GET /buildings.xml
  def index
    @buildings = Building.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @buildings }
    end
  end

  def administration
    @buildings = Building.find(:all)
  end

  # GET /buildings/1
  # GET /buildings/1.xml
  def show
    @building = Building.find(params[:id])
    @address = Address.find(@building.address_id)
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @building }
    end
  end

  def new
    @building = Building.new
    @address = Address.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @building }
    end
  end

  # GET /buildings/1/edit
  def edit
    @building = Building.find(params[:id])
    @address = Address.find(@building.address_id)
  end

  # POST /buildings
  # POST /buildings.xml
  def create
    @building = Building.new(params[:building])
    @address = Address.new(params[:address])

    Building.transaction do
      @building.address = @address
    end

    respond_to do |format|
      if @building.save and @address.save
        flash[:notice] = 'Building e relativo Address inseriti correttamente nel DB '
        format.html { redirect_to :action => 'administration' }
        format.xml  { render :xml => @building, :status => :created, :location => @building }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @building.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /buildings/1
  # PUT /buildings/1.xml
  def update
    @building = Building.find(params[:id])
    @address = Address.find(@building.address_id)

    respond_to do |format|
      if @building.update_attributes(params[:building]) and @address.update_attributes(params[:address])
        flash[:notice] = 'Building was successfully updated.'
        format.html { redirect_to :action => 'administration' }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @building.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /buildings/1
  # DELETE /buildings/1.xml
  def destroy
    @building = Building.find(params[:id])
    @building.destroy

    respond_to do |format|
      format.html { redirect_to :action => 'administration' }
      format.xml  { head :ok }
    end
  end
end
