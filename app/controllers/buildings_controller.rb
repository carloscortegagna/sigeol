#=QuiXoft - Progetto SIGEOL
#NOME FILE:: buildings_controller.rb
#AUTORE:: Carlo Scortegagna
#DATA CREAZIONE:: 13/02/2009
#REGISTRO DELLE MODIFICHE::
# 01/06/2009 aggiunta lista delle aula nella vista pubblica index
#
# 21/05/2009 Aggiunto sia su create che su update le istruzioni che generano il contenuto di telephone usando i parametri prefisso e telefono.
# Inoltre inserite istruzioni necessarie per renderizzare il contenuto con js.
#
# 14/05/2009 completate le viste xml
#
# 03/03/2009 Aggiornato il controller buildings con l'aggiunta dei filtri che mancavano
#
# 13/02/2009 prima stesura del controller


class BuildingsController < ApplicationController

  # metodi che non devono essere sottoposti al filtro login_required, in quanto di pubblico accesso
  # tutti gli altri metodi non esplicitamente elencati verranno sottoposti al filtro login_required
  skip_before_filter :login_required, :only => [:index, :show]

  # tutti i metodi sono sottoposti al filtro manage_buildings_required, ad eccezione di quelli elencati nel paramentro :except
  before_filter :manage_buildings_required, :except => [:index, :show]
  before_filter :building_with_classroom_in_use, :only => [:destroy, :edit]

  # metodo che inizializza le variabili d'istanza @buildings e @classrooms per la vista index
  def index
    @buildings = (Building.find(:all)).sort_by { |b| b[:name] }
    @classrooms = Classroom.find(:all)
    respond_to do |format|
      format.html
      format.xml { render :xml => @buildings.to_xml(:include => :classrooms, :except =>[:created_at, :updated_at]) } # index xml
    end
  end

  # metodo che inizializza la variabile d'istanza @buildings per la vista administration
  def administration
    @buildings = Building.find(:all)
  end

  # metodo che inizializza le variabili d'istanza @building, @building_classrooms e @address per la vista show
  def show
    notfound = false
    @building = Building.find(params[:id]) rescue notfound = true
    unless notfound
     @building_classrooms = Classroom.find(:all, :conditions => { :building_id => params[:id] }) #lista delle aule di quell'edificio
     @address = Address.find(@building.address_id)
     end
    respond_to do |format|
      format.html {
          if notfound
            redirect_to :controller => 'timetables', :action => 'not_found'
          end
          }
      format.xml {
          if notfound
            redirect_to :controller => 'timetables', :action => 'not_found'
          else
            render :xml => @building.to_xml(:include =>[:address, :classrooms], :except =>[:created_at, :updated_at, :id, :building_id, :address_id])  # show xml
          end
          }
      end
  end

  # metodo che crea 2 nuove variabili d'istanza (@building e @address) per la vista new
  def new
    @building = Building.new
    @address = Address.new
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # metodo che inizializza le variabili d'istanza @building e @address per la vista edit
  def edit
    notfound = false
    @building = Building.find(params[:id]) rescue notfound = true
    unless notfound
     @address = Address.find(@building.address_id)
    end
    respond_to do |format|
        format.html {
          if notfound
            redirect_to :controller => 'timetables', :action => 'not_found'
          end
          }
    end
  end

  # Salva un nuovo building e il suo relativo address nel sistema, caratterizzati rispettivamente dai
  # parametri contenuti in params[:building] e in params[:address].
  # In caso di esito positivo viene fatto un redirect alla vista administration di building.
  # In caso di problemi nel salvataggio, viene riproposta la vista new e vengono segnalati gli eventuali errori.
  def create
    @building = Building.new(params[:building])
    @address = Address.new(params[:address])
    @address.telephone= ""
    if(params[:prefisso] != "" || params[:telefono] != "") #se i parametri prefisso e telefono non sono vuoti compilo il campo dati telephone
    @address.telephone = params[:prefisso]+"-"+params[:telefono]
    end
    respond_to do |format|
      if @address.save #salvo innanzitutto l'indirizzo
        @building.address = @address #lego l'indirizzo all'edificio da salvare
        if @building.save #se il salvataggio dell'edificio va a buon fine...
          flash[:notice] = 'Inserimento del nuovo edificio avvenuto con successo'
          format.html { redirect_to :action => 'administration' }
          format.js{render(:update) {|page| page.redirect_to :action => 'administration'}}
        else
          Address.find(@building.address_id).destroy #cancello l'address salvato nel DB, non e' puntato da nessun building
          format.html { render :action => "new" }
          format.js{}
        end
      else
        format.html { render :action => "new" }
        format.js{}
      end
    end
  end

  # Metodo che aggiorna i campi dato dell'edificio oggetto di invocazione nel sistema, insieme al suo indirizzo.
  # In caso di esito positivo viene fatto un redirect alla vista administration di building.
  # In caso di problemi nel'aggiornamento, viene riproposta la vista edit e vengono segnalati gli eventuali errori.
  def update
    @building = Building.find(params[:id]) #edificio da modificare
    @address = Address.find(@building.address_id) #relativo indirizzo da modificare
    @address.telephone= ""
    if(params[:prefisso] != "" || params[:telefono] != "") #se i parametri prefisso e telefono non sono vuoti compilo il campo dati telephone
    @address.telephone = params[:prefisso]+"-"+params[:telefono]
    end
    respond_to do |format|
      if @building.update_attributes(params[:building]) and @address.update_attributes(params[:address]) #se l'aggiornamento dell'edificio e dell'indirizzo vanno a buon fine
        flash[:notice] = "Modifica dell'edificio completata correttamente"
        format.html { redirect_to :action => 'administration' }
        format.js{render(:update) {|page| page.redirect_to :action => 'administration'}}
      else
        format.html { render :action => "edit" }
        format.js{ render :action => "create.js.rjs" }
      end
    end
  end

  # Metodo che elimina definitivamente dal DB l'edificio oggetto di invocazione e il suo indirizzo.
  # Dopo la distruzione viene fatto un redirect alla vista administration di building.
  def destroy
    @building = Building.find(params[:id])
    Address.find(@building.address_id).destroy #distruzione dell'indirizzo relativo al building da cancellare
    @building.destroy
    respond_to do |format|
      format.html { redirect_to :action => 'administration' }
    end
  end
  private

  def building_with_classroom_in_use
    notfound = false
    errors = false
    name = nil
    building = Building.find(params[:id]) rescue notfound = true
    unless notfound
      (building.classrooms).each do |c|
        c.graduate_courses.each do |g|
          if g.timetables_in_generation?
            name = g.name
            errors = true;
            break
          end
        end
        if errors
          break
        end
      end
      if errors
        flash[:error] = "Non è possibile modificare questo edificio in quanto almeno una delle sue aule è in uso per la generazione dell'orario per il corso di laurea " +name
       redirect_to administration_buildings_url
      end
    else
      redirect_to :controller => 'timetables', :action => 'not_found'
    end
  end
  
  
end
