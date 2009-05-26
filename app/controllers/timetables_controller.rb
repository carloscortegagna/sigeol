# QuiXoft - Progetto ”SIGEOL”
# NOME FILE: timetables.controller.rb
# AUTORE: Barbiero Mattia
# DATA CREAZIONE: 13/02/2009
#
# REGISTRO DELLE MODIFICHE:
#
# 13/02/2009 aggiunto il controller per timetables. L'home page del progetto è l'index di questo controller

require 'net/http'
require 'net/https'

class TimetablesController < ApplicationController
  skip_before_filter :login_required
  
  def index
    @timetables = Timetable.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @timetables.to_xml }
    end
  end

  def show
    @timetable = Timetable.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @timetable }
    end
  end

  def new
    @timetable = Timetable.new

    respond_to do |format|
      format.html
      format.xml  { render :xml => @timetable.to_xml }
    end
  end

  def edit
    @timetable = Timetable.find(params[:id])
  end

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

  def destroy
    @timetable = Timetable.find(params[:id])
    @timetable.destroy

    respond_to do |format|
      format.html { redirect_to(timetables_url) }
      format.xml  { head :ok }
    end
  end
  
  #metodo usato nella creazione di una nuova istanza di schedulazione
  #chiamato dalla gui
  def schedule
    #URL della servlet
    url = URI.parse('http://localhost:8080/middleman/scheduler.do')
    #impostazione del metodo POST
    req = Net::HTTP::Post.new(url.path)
    #parametri di autenticazione
    #req.basic_auth 'jack', 'pass'
    #dati da inviare op = ScheduleJob
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
  #chiamato dalla servlet via get
  def notify
    if start
      head :ok
    else
      head :unavailable
    end
  end

  #metodo per la segnalazione del calcolo dell'algoritmo eseguito
  #eseguito dalla servlet via get
  def done
    #prendi valore course e effettuta operazione di finalizzazione
    @timetable = Timetable.find(params[:id])
    if true
    head :ok
    else
    head :unavailable
    end
  end

  #eseguito dalla GUI
  def start
    done = false
    #prepara il file di input

    #URL della servlet
    url = URI.parse('http://localhost/middleman/scheduler.do')
    #impostazione del metodo POST
    req = Net::HTTP::Post.new(url.path)
    #parametri di autenticazione
    #req.basic_auth 'jack', 'pass'
    #dati da inviare op = DoJob
    #TODO prelevare corso, creare file input, scegliere un valore di timeout
    req.set_form_data({'op'=>'dj','course'=>'', 'inputfile'=>'','timeout'=>''}, ';')
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
