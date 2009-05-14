require 'net/http'
require 'net/https'

class TimetablesController < ApplicationController
  skip_before_filter :login_required
  
  # GET /timetables
  # GET /timetables.xml
  def index
    @timetables = Timetable.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @timetables }
    end
  end

  # GET /timetables/1
  # GET /timetables/1.xml
  def show
    @timetable = Timetable.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @timetable }
    end
  end

  # GET /timetables/new
  # GET /timetables/new.xml
  def new
    @timetable = Timetable.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @timetable.to_xml }
    end
  end

  # GET /timetables/1/edit
  def edit
    @timetable = Timetable.find(params[:id])
  end

  # POST /timetables
  # POST /timetables.xml
  def create
    @timetable = Timetable.new(params[:timetable])

    respond_to do |format|
      if @timetable.save
        flash[:notice] = 'Timetable was successfully created.'
        format.html { redirect_to(@timetable) }
        format.xml  { render :xml => @timetable, :status => :created, :location => @timetable }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @timetable.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /timetables/1
  # PUT /timetables/1.xml
  def update
    @timetable = Timetable.find(params[:id])

    respond_to do |format|
      if @timetable.update_attributes(params[:timetable])
        flash[:notice] = 'Timetable was successfully updated.'
        format.html { redirect_to(@timetable) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @timetable.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /timetables/1
  # DELETE /timetables/1.xml
  def destroy
    @timetable = Timetable.find(params[:id])
    @timetable.destroy

    respond_to do |format|
      format.html { redirect_to(timetables_url) }
      format.xml  { head :ok }
    end
  end
  
  #
  #metodo usato nella creazione di una nuova istanza di schedulazione
  #
  def schedule
    #URL della servlet
    url = URI.parse('http://localhost:8080/middleman/scheduler.do')
    #impostazione del metodo POST
    req = Net::HTTP::Post.new(url.path)
    #parametri di autenticazione
    #req.basic_auth 'jack', 'pass'
    #dati da inviare
    req.set_form_data({'op'=>'sj', 'course'=>'corso', 'date'=>'data_scheduling'}, ';')
    #connessione alla servlet
    res = Net::HTTP.new(url.host, url.port).start {
      |http| http.request(req)
    }
    #controllo del codice di errore
    case res
      when Net::HTTPSuccess, Net::HTTPRedirection
      # OK
      when Net::HTTPNotAcceptable
      #parametri non corretti.. riportare alla form
      else
      #errore connessione.. riprovare
    end
  end
  
  #
  #metodo per la segnalazione di avvio calcolo algoritmo
  #
  def notify
    if start
      head :ok
    else
      head :unavailable
    end
  end

  #
  #metodo per la segnalazione del calcolo dell'algoritmo eseguito
  #
  def done
    #prendi valore course e effettuta operazione di finalizzazione
    if true
    head :ok
    else
    head :unavailable
    end
  end

  def start
    done = false
    #prepara il file di input

    #URL della servlet
    url = URI.parse('http://localhost/middleman/scheduler.do')
    #impostazione del metodo POST
    req = Net::HTTP::Post.new(url.path)
    #parametri di autenticazione
    #req.basic_auth 'jack', 'pass'
    #dati da inviare
    #TODO prelevare corso, creare file input, scegliere un valore di timeout
    req.set_form_data({'course'=>'corso', 'inputfile'=>'file_name','timeout'=>'time'}, ';')
    #connessione alla servlet
    res = Net::HTTP.start(url.host, url.port) {
      |http| http.request(req)
    }

    #controllo del codice di errore
    case res
      when Net::HTTPSuccess, Net::HTTPRedirection
      # OK
      done = true
      when Net::HTTPNotAcceptable
      #parametri non corretti.. riportare alla form
      else
      #errore connessione.. riprovare
    end
    return done
  end

end
# pdf converter
 #def _index
#   @items = Item.find(:all)
# end
