#=QuiXoft - Progetto ”SIGEOL”
#NOME FILE:: buildings_controller.rb
#VERSIONE:: 1.0.0
#AUTORE:: ???
#DATA CREAZIONE:: ???
#REGISTRO DELLE MODIFICHE::
# 21/05/2009 Aggiunto sia su create che su update le istruzioni che generano il contenuto di telephone usando i paramentri prefisso e telefono.
# Inoltre inserite istruzioni necessarie per renderizzare il contenuto con js.

class BuildingsController < ApplicationController
  skip_before_filter :login_required, :only => [:index, :show]
  before_filter :manage_buildings_required, :except => [:index, :show]

  def index
    @buildings = (Building.find(:all)).sort_by { |b| b[:name] }
    respond_to do |format|
      format.html
      format.xml { render :xml => @buildings.to_xml(:include => :classrooms, :except =>[:created_at, :updated_at]) } # index xml
    end
    #respond_to { |format| format.js}
  end

  def administration
    @buildings = Building.find(:all)
  end

  def show
    @building = Building.find(params[:id])
    @building_classrooms = Classroom.find(:all, :conditions => { :building_id => params[:id] })
    @address = Address.find(@building.address_id)
    respond_to do |format|
      format.html # show.html.erb
      format.xml { render :xml => @building.to_xml(:include =>[:address, :classrooms], :except =>[:created_at, :updated_at, :id, :building_id, :address_id]) } # show xml
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
    @address.telephone= ""
    if(params[:prefisso] != "" || params[:telefono] != "")
    @address.telephone = params[:prefisso]+"-"+params[:telefono]
    end
    respond_to do |format|
      if @address.save
        @building.address = @address
        if @building.save
          flash[:notice] = 'Inserimento del nuovo edificio avvenuto con successo'
          format.html { redirect_to :action => 'administration' }
          format.js{redirect_to :action => 'administration'}
        else
          Address.find(@building.address_id).destroy # cancello l'address salvato nel DB, non è puntato da nessun building
          format.html { render :action => "new" }
          format.js{}
        end
      else
        format.html { render :action => "new" }
        format.js{}
      end
    end
  end

  # PUT /buildings/1
  # PUT /buildings/1.xml
  def update
    @building = Building.find(params[:id])
    @address = Address.find(@building.address_id)
    @address.telephone= ""
    if(params[:prefisso] != "" || params[:telefono] != "")
    @address.telephone = params[:prefisso]+"-"+params[:telefono]
    end
    respond_to do |format|
      if @building.update_attributes(params[:building]) and @address.update_attributes(params[:address])
        flash[:notice] = "Modifica dell'edificio completata correttamente"
        format.html { redirect_to :action => 'administration' }
        format.js{render(:update) {|page| page.redirect_to :action => 'administration'}}
      else
        format.html { render :action => "edit" }
        format.js{ render :action => "create.js.rjs" }
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
