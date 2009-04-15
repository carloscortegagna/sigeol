class BuildingsController < ApplicationController
  skip_before_filter :login_required, :only => [:index, :show]
  before_filter :manage_buildings_required, :except => [:index, :show]

  def index
    @buildings = Building.find(:all)
    @classrooms = Classroom.find(:all)

    respond_to do |format|
      format.html
    end
  end

  def administration
    @buildings = Building.find(:all)
  end

  def show
    @building = Building.find(params[:id])
    @address = Address.find(@building.address_id)
    respond_to do |format|
      format.html # show.html.erb
    end
  end

  def new
    @building = Building.new
    @address = Address.new

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /buildings/1/edit
  def edit
    @building = Building.find(params[:id])
    @address = Address.find(@building.address_id)
  end

  # POST /buildings
  def create
    @building = Building.new(params[:building])
    @address = Address.new(params[:address])

    respond_to do |format|
      if @address.save
        @building.address = @address
        if @building.save
          flash[:notice] = 'Inserimento del nuovo edificio avvenuto con successo'
          format.html { redirect_to :action => 'administration' }
        else
          Address.find(@building.address_id).destroy # cancello l'address salvato nel DB, non è puntato da nessun building
          format.html { render :action => "new" }
        end
      else        
        format.html { render :action => "new" }
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
        flash[:notice] = "Modifica dell'edificio completata correttamente"
        format.html { redirect_to :action => 'administration' }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  # DELETE /buildings/1
  # DELETE /buildings/1.xml
  def destroy
    @building = Building.find(params[:id])
    Address.find(@building.address_id).destroy
    @building.destroy

    respond_to do |format|
      format.html { redirect_to :action => 'administration' }
    end
  end
end
