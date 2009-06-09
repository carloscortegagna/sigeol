#=QuiXoft - Progetto ”SIGEOL”
#NOME FILE:: timetables.controller.rb
#AUTORE:: Barbiero Mattia
#DATA CREAZIONE:: 13/02/2009
#REGISTRO DELLE MODIFICHE::
# 13/02/2009 aggiunto il controller per timetables. L'home page del progetto è l'index di questo controller


require 'net/http'
require 'net/https'

class TimetablesController < ApplicationController
  skip_before_filter :login_required, :only => [:index, :show]
  before_filter :correct_url_parameter ,:only => [:new, :create, :destroy_all]
  before_filter :only_one_group_of_timetable, :only => [:new, :create]
  protect_from_forgery :only => [:create, :update, :destroy, :show, :index, :new, :edit]
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
      format.xml  { render :xml => @timetable.to_xml }
    end
  end

  def create
    graduate_course = GraduateCourse.find(params[:graduate_course])
    unless (params[:duration])
      flash[:error] = "Durata non inserita"
      error = true
    end
    unless (params[:start_hour2] and params[:end_hour2])
      if ((params[:start_hour2] > params[:end_hour2]) or (params[:start_hour1] > params[:start_hour2]) or
          (params[:end_hour1] < params[:end_hour2]))
        flash[:error] = "La combinazione tra le ore di pausa e quelle di lezione è errata"
        error = true
      end
    end
    unless error
      start1 = Time.parse(params[:start_hour1])
      end1 = Time.parse(params[:end_hour1])
      start2 = nil
      end2 = nil
      unless (params[:start_hour2] and params[:end_hour2])
        start2 = Time.parse(params[:start_hour2])
        end2 = Time.parse(params[:end_hour2])
      end
      if (start2 != nil and end2 != nil)
        range1 = ((start2 - start1).divmod(params[:duration].to_i*60))[1]
        range2 = ((end1 - end2).divmod(params[:duration].to_i*60))[1]
        unless ((range1.zero?) and (range2.zero?))
          error = true;
          flash[:error] = "L'intervallo di tempo non è multiplo della durata scelta"
        end
      else
        range = ((end1 - start1).divmod(params[:duration].to_i*60))[1]
        unless (range.zero?)
          error = true
          flash[:error] = "L'intervallo di tempo non è multiplo della durata scelta"
        end
      end
      unless (error)
        Timetable.transaction do
          destroy_old_contraints(graduate_course.id)
          for i in 1..5
            graduate_course.constraints << TemporalConstraint.create(:description=>"Orario delle lezioni",
                :isHard=>0,:startHour=>"00:00",:endHour=>params[:start_hour1],:day=>i)
          end
          for i in 1..5
            graduate_course.constraints << TemporalConstraint.create(:description=>"Orario delle lezioni",
                :isHard=>0,:startHour=>params[:end_hour1],:endHour=>"23:59",:day=>i)
          end
          if (params[:start_hour2] and params[:end_hour2])
            for i in 1..5
              graduate_course.constraints << TemporalConstraint.create(:description=>"Pausa delle lezioni",
                  :isHard=>0,:startHour=>params[:start_hour2],:endHour=>params[:end_hour2],:day=>i)
            end
          end
          for i in 1..5
            graduate_course.constraints << QuantityConstraint.create(:description => "Durata delle lezioni",
                   :isHard => 0, :quantity => params[:duration].to_i)
          end
          exp_date = graduate_course.expiry_dates.find(:first, :conditions => {:period => params[:subperiod]})
          unless exp_date
            exp_date = graduate_course.expiry_dates.build()
          end
          exp_date.period = params[:subperiod]
          exp_date.date = Date.civil(params[:range][:"expiry_date(1i)"].to_i,
                                     params[:range][:"expiry_date(2i)"].to_i,
                                     params[:range][:"expiry_date(3i)"].to_i)
          exp_date.save
          for i in 1..graduate_course.academic_organization.number
            period = Period.find_by_year_and_subperiod(i,params[:subperiod])
            graduate_course.timetables.create(:period => period, :year => params[:year], :isPublic => false)
          end
        end
      end
    end
    respond_to do |format|
      format.html {
        if error
          unless flash[:error]
            flash[:error] = "Errore nella creazione dell'orario. Controllare i campi"
          end
        else
          flash[:notice] = "Richiesta inviata correttamente alla servlet"
        end
        redirect_to administration_timetables_url
      }
    end
  end

  def destroy_all
    gs = GraduateCourse.find(params[:graduate_course])
    for i in 1..gs.academic_organization.number
      period = Period.find_by_year_and_subperiod(i,params[:subperiod])
      t = Timetable.find(:first,
      :conditions => ["graduate_course_id = ? AND period_id = ? AND year = ?", gs.id, period, params[:year]])
      t.delete
    end
    respond_to do |format|
      format.html { redirect_to administration_timetables_url }
    end
  end

  def new
  end

  def administration
    ids = @current_user.graduate_course_ids
    @graduate_courses = GraduateCourse.find(:all, :include => :timetables,
                            :conditions => ["graduate_courses.id IN (?)", ids])
    @timetables = Hash.new
    @graduate_courses.each do |g|
      @timetables[g] = Hash.new
      last_year = nil
      g.timetables.group_by(&:year).each do |y, t|
        @timetables[g][y] = Hash.new
        last_year = y.to_s
        for i in 1..g.academic_organization.number
          timet = g.timetables.find(:all, :include => :period,
                                    :conditions => ["timetables.year = ? AND periods.subperiod = ?", y, i])
          @timetables[g][y][i] = timet unless timet.empty?
          @timetables[g][y][i] = nil if timet.empty?
        end
      end
      if last_year != TimetablesHelper::current_year
        @timetables[g][TimetablesHelper::current_year] = Hash.new
        for i in 1..g.academic_organization.number
          @timetables[g][TimetablesHelper::current_year][i] = nil
        end
      end
    end
  end

  #metodo usato nella creazione di una nuova istanza di schedulazione
  #chiamato dalla gui
  def schedule
    #URL della servlet
    url = URI.parse(CONFIG['servlet']['address'])
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

  private
    def correct_url_parameter
      errors = false;
      unless params[:graduate_course] && params[:subperiod] && params[:year]
        flash[:error] = "Indirizzo non creato correttamente"
        errors = true;
      end
      unless errors
        ids = @current_user.graduate_course_ids
        unless ids.include?(params[:graduate_course].to_i)
          flash[:error] = "Non puoi modificare un orario per un corso di laurea che non ti appartiene"
          errors = true;
        end
      end
      unless request.delete?
        unless errors
          period_ids = Period.find(:all, :conditions => {:subperiod => params[:subperiod].to_i})
          timetable = Timetable.find(:all,
            :conditions => ["graduate_course_id = ? AND year = ? AND period_id IN (?)", params[:graduate_course].to_i, params[:year], period_ids])
          unless timetable.empty?
            flash[:error] = "L'orario per questo periodo ed anno accademico è gia stato generato"
            errors = true
          end
        end
      end
        redirect_to administration_timetables_url if errors
    end

    def only_one_group_of_timetable
      graduate_course = GraduateCourse.find(params[:graduate_course])
      timetables = graduate_course.timetables
      error = false
      timetables.each do |t|
        if t.timetable_entries.empty?
          error = true
        end
      end
      if error
        flash[:error] = "E' permessa la generazione degli orari per un solo periodo per volta"
        redirect_to administration_timetables_url
      end
    end

    def destroy_old_contraints(gs_id)
      graduate_course = GraduateCourse.find(gs_id)
      orario_lezioni = (graduate_course.temporal_constraints).find_all_by_description("Orario delle lezioni")
      pausa_lezioni = (graduate_course.temporal_constraints).find_all_by_description("Pausa delle lezioni")
      duarata_lezioni = (graduate_course.quantity_constraints).find_all_by_description("Duarata delle lezioni")
      orario_lezioni.each do |c|
        c.destroy
      end
      pausa_lezioni.each do |c|
        c.destroy
      end
      duarata_lezioni.each do |c|
        c.destroy
      end
    end
end

# pdf converter
 #def _index
#   @items = Item.find(:all)
# end
