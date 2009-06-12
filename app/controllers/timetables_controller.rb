#=QuiXoft - Progetto SIGEOL
#NOME FILE:: timetables.controller.rb
#AUTORE:: Barbiero Mattia
#DATA CREAZIONE:: 13/02/2009
#REGISTRO DELLE MODIFICHE::
# 13/02/2009 aggiunto il controller per timetables. L'home page del progetto e' l'index di questo controller
#

require 'net/http'
require 'net/https'

class TimetablesController < ApplicationController
  skip_before_filter :login_required , :only => [:index, :show, :notify, :done]
  before_filter :correct_url_parameter ,:only => [:new, :create, :destroy_all, :publicize_all_timetables]
  before_filter :only_one_group_of_timetable, :only => [:new, :create]
  before_filter :manage_timetables_required, :except [:index,:show, :notify, :done]
  protect_from_forgery :except => [:notify, :done]
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
    exp_date = nil
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
            temporal = TemporalConstraint.create(:description=>"Orario delle lezioni",
                :isHard=>0,:startHour=>"00:00",:endHour=>params[:start_hour1],:day=>i)
            graduate_course.constraints << temporal
          end
          for i in 1..5
            temporal = TemporalConstraint.create!(:description=>"Orario delle lezioni",
                :isHard=>0,:startHour=>params[:end_hour1],:endHour=>"23:59",:day=>i)
            graduate_course.constraints << temporal
          end
          if (start2 and end2)
            for i in 1..5
              temporal = TemporalConstraint.create!(:description=>"Pausa delle lezioni",
                  :isHard=>0,:startHour=>params[:start_hour2],:endHour=>params[:end_hour2],:day=>i)
              graduate_course.constraints << temporal
            end
          end
          for i in 1..5
            graduate_course.constraints << QuantityConstraint.create!(:description => "Durata delle lezioni",
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
          for i in 1..graduate_course.duration
            period = Period.find_by_year_and_subperiod(i,params[:subperiod])
            graduate_course.timetables.create(:period => period, :year => params[:year], :isPublic => false)
          end
        end
        unless (schedule(params[:subperiod], params[:year],graduate_course, exp_date))
          error = true
          destroy_old_contraints(graduate_course.id)
          exp_date.destroy
          flash[:error] = "Richiesta alla servlet fallita. Riprovare"
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
    for i in 1..gs.duration
      period = Period.find_by_year_and_subperiod(i,params[:subperiod])
      t = Timetable.find(:first,
      :conditions => ["graduate_course_id = ? AND period_id = ? AND year = ?", gs.id, period, params[:year]])
      t.destroy
    end
    respond_to do |format|
      flash[:notice] = "Tabelle orarie eliminate con successo"
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

  def publicize_all_timetables
    gs = GraduateCourse.find(params[:graduate_course])
    for i in 1..gs.duration
      period = Period.find_by_year_and_subperiod(i,params[:subperiod])
      t = Timetable.find(:first,
      :conditions => ["graduate_course_id = ? AND period_id = ? AND year = ?", gs.id, period, params[:year]])
      t.isPublic = true
      t.save
    end
    respond_to do |format|
      flash[:notice] = "Orario pubblicato con successo"
      format.html { redirect_to administration_timetables_url }
    end
  end

  #metodo usato nella creazione di una nuova istanza di schedulazione
  #chiamato dalla gui
  def schedule(subperiod,year,gs,expiry_date)
    #URL della servlet
    url = URI.parse(CONFIG['servlet']['address'])
    #impostazione del metodo POST
    req = Net::HTTP::Post.new(url.path)
    #parametri di autenticazione
    #req.basic_auth 'jack', 'pass'
    #dati da inviare op = ScheduleJob
    data = expiry_date.date
    day = data.day.to_i
    if day < 10
      day = "0" + day.to_s
    else
      day = day.to_s
    end
    month = data.mon.to_i
    if month < 10
      month = "0" + month.to_s
    else
      month = month.to_s
    end
    date = day + "-" + month + "-" + data.year.to_s
    req.set_form_data({'op'=>'sj', 'graduate_course' => gs.id.to_s,
                       'year' => year,
                       'subperiod' => subperiod.to_s,
                       'date'=> date}, '&')
    
    #connessione alla servlet
    res = Net::HTTP.new(url.host, url.port).start {
      |http| http.request(req)
    }
    #controllo del codice di errore
    case res
      when Net::HTTPSuccess, Net::HTTPRedirection
      # OK
      return true
      when Net::HTTPNotAcceptable
      #parametri non corretti.. riportare alla form
      return false
      else
      #errore connessione.. riprovare
      return false
    end
  end
  
  #
  #metodo per la segnalazione di avvio calcolo algoritmo
  #chiamato dalla servlet via get
  def notify
    graduate_course = GraduateCourse.find(params[:graduate_course])
    subperiod = params[:subperiod].to_i
    year = params[:year]
    if start(graduate_course,subperiod,year)
      head :ok
    else
      head :unavailable
    end
  end

  #metodo per la segnalazione del calcolo dell'algoritmo eseguito
  #eseguito dalla servlet via get
  def done
    #prendi valore course e effettuta operazione di finalizzazione
    params[:input_file]
    gs = GraduateCourse.find(params[:graduate_course])
    year = params[:year]
    subperiod = params[:subperiod]
    filename = "test.out"
    File.open(filename, "wb") do |f|
      f.write(params[:input_file].read)
    end
    process_file(gs, year, subperiod, filename)
    if true
    head :ok
    else
    head :unavailable
    end
  end

  #eseguito dalla GUI
  def start(gs,subperiod, year)
    done = false
    #prepara il file di input
    filename = create_input_file(gs,subperiod)
    file = File.open(filename,"rb")
    post = Hash.new
    post["op"] = "dj"
    post["graduate_course"] = gs.id
    post["year"] = year
    post["subperiod"] = subperiod
    post["inputfile"] = file
    mp = TimetablesHelper::MultipartPost.new
    query, headers = mp.prepare_query(post)
    file.close
    #file.delete
    #URL della servlet
    url = URI.parse(CONFIG['servlet']['address'])
    #impostazione del metodo POST
    res = TimetablesHelper::post_form(url, query, headers)
    #controllo del codice di errore
    case res
      when Net::HTTPSuccess, Net::HTTPRedirection
      # OK
      done = true
      when Net::HTTPNotAcceptable
      #parametri non corretti.. riportare alla form
          done = false
      else
        done = false
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

    def create_input_file(gs, subp)
    graduate_course = gs
    subperiod = subp
    curricula = graduate_course.curriculums
    doppi = 0
    teachings = find_teachings(subperiod,gs)
    teachings.each do |t|
      if (t.labHours.to_i) > 0
        doppi = doppi + 1
      end
    end
    periods = calculate_periods(gs)
    rooms = graduate_course.classrooms
    filename = "input"+subperiod.to_s+"-"+gs.name+".ctt"
    File.open(filename, "w") do |f|
      f.puts "Name: " + gs.name
      f.puts "Courses: " + (teachings.size + doppi).to_s
      f.puts "Rooms: " + (rooms.size).to_s
      f.puts "Days: 5"
      f.puts "Periods_per_day: " + (periods.size).to_s
      f.puts "Curricula: " + (curricula.size * gs.duration).to_s
      f.puts "Constraints: 100"
      f.puts "\n"
      f.puts "COURSES:"
      print_courses(teachings,f)
      f.puts "\n"
      f.puts "ROOMS:"
      rooms.each do |r|
        if r.lab == false
          type = "TEO"
        else
          type = "LAB"
        end
        f.puts r.id.to_s + " " + r.capacity.to_s + " " + type
      end
      f.puts "\n"
      f.puts "CURRICULA:"
      for i in 1..graduate_course.duration
        curricula.each do |c|
          curriculum_id = c.id.to_s + "-" + i.to_s
          t = find_teachings_by_curriculum(subperiod,c.id,i,gs)
          cont = 0
          course_list = String.new
          t.each do |k|
            course_list << " " + k.id.to_s + "-teo"
            cont += 1
            if k.labHours > 0
              cont +=1
              course_list << " " + k.id.to_s + "-lab"
            end
          end
          f.puts curriculum_id + " " + cont.to_s + course_list
        end
      end
      f.puts "\n"
      f.puts "UNAVAILABILITY_CONSTRAINTS:"
      print_constraints(f, teachings, periods)
      f.puts "\n"
      f.puts "PREFERENCES:"
      print_preferences(f, teachings, periods)
      f.puts "\n"
      f.puts "ROOM_CONSTRAINT:"
      print_room_constraints(f, rooms, periods)
    end
    filename
  end

  def print_courses(teachings, f)
    teachings.each do |t|
        if t.teacher
          teacher = t.teacher.id.to_s
        else
          teacher = "nil"
        end
          hours = t.classHours
          group = ((hours.to_f)/2).ceil
          group = 5 if group > 5
          if t.studentsNumber
            student = t.studentsNumber.to_s
          else
            student = 0.to_s
          end
        if t.labHours > 0
          hours_l = t.labHours
          group_l = ((hours_l.to_f)/2).ceil
          group_l = 5 if group_l > 5
          f.puts t.id.to_s + "-lab " + teacher + " " + hours_l.to_s + " " + group_l.to_s +
                " " + student + " LAB"
        end
        f.puts t.id.to_s + "-teo " + teacher + " " + hours.to_s + " " + group.to_s +
                " " + student + " TEO"
      end
  end

  def print_room_constraints(file,rooms, periods)
    rooms.each do |r|
      constraints = r.temporal_constraints.find(:all, :conditions => ["isHard = 0"])
      constraints.each do |c|
        slots = compute_slots(c.startHour, c.endHour, periods)
        slots.each do |s|
          file.puts r.id.to_s + " " + (c.day - 1).to_s + " " + s.to_s
        end
      end
    end
  end
  def print_constraints(file, teachings, periods)
    teachings.each do |t|
      teacher = t.teacher
      unless teacher == nil
        constraints = teacher.temporal_constraints.find(:all, :conditions => ["isHard = 0"])
        constraints.each do |c|
          slots = compute_slots(c.startHour, c.endHour, periods)
          slots.each do |s|
            file.puts t.id.to_s + " " + (c.day - 1).to_s + " " + s.to_s
          end
        end
      end
    end
  end

  def print_preferences(file, teachings, periods)
    teachers = Array.new
    teachings.each do |teaching|
      teachers << teaching.teacher
    end
    teachers.uniq!
    teachers.each do |teacher|
      unless teacher == nil
        preferences = teacher.temporal_constraints.find(:all, :conditions => ["isHard != 0"])
        preferences.each do |p|
          slots = compute_slots(p.startHour, p.endHour, periods)
          slots.each do |s|
            file.puts teacher.id.to_s + " " + (p.day - 1).to_s + " " + s.to_s + " " + p.isHard.to_s
          end
        end
      end
    end
  end
  def compute_slots(startHour,endHour,periods)
    slots = Array.new
    periods.each do |p|
      t1 = p["start"]
      t2 = p["end"]
      unless ((startHour <= t1 && endHour <= t1) || (endHour >= t2 && startHour >= t2 ))
        slots << periods.index(p)
      end
    end
    slots
  end

  def calculate_periods (gs)
    g = gs
    first_constraint = g.temporal_constraints.find(:all,
              :conditions => ["description = ? AND startHour = ?","Orario delle lezioni", "00:00"])
    last_constraint = g.temporal_constraints.find(:all,
              :conditions => ["description = ? AND endHour = ?","Orario delle lezioni", "23:59"])
    pause_constraint = g.temporal_constraints.find(:all,
              :conditions => ["description = ?","Pausa delle lezioni"])
    duration = g.quantity_constraints.find(:first,
                :conditions => ["description = ?", "Durata delle lezioni"])
      t1 = Time.parse((first_constraint[0].endHour).to_s)
      t2 = Time.parse((last_constraint[0].startHour).to_s)
      period = (t2-t1)/((duration.quantity)*60)
      t1_pause = nil
      t2_pause = nil
      unless pause_constraint.empty?
        t1_pause = Time.parse((pause_constraint[0].startHour).to_s)
        t2_pause = Time.parse((pause_constraint[0].endHour).to_s)
      end
      if pause_constraint.empty?
        periods = Array.new
        periods[0] = Hash.new
        periods[0]["start"] = t1
        periods[0]["end"] = t1 + (duration.quantity)*60
        for i in 1..Integer(period-1)
          periods[i] = Hash.new
          periods[i]["start"] = periods[i-1]["end"]
          periods[i]["end"] = periods[i]["start"] + (duration.quantity)*60
        end
      else
        periods = Array.new
        periods[0] = Hash.new
        periods[0]["start"] = t1
        periods[0]["end"] = t1 + (duration.quantity)*60
        p = (t1_pause - t1)/((duration.quantity)*60)
        for i in 1..Integer(p-1)
          periods[i] = Hash.new
          periods[i]["start"] = periods[i-1]["end"]
          periods[i]["end"] = periods[i]["start"] + (duration.quantity)*60
        end
        p1 = (t2 - t2_pause)/((duration.quantity)*60)
        periods[p] = Hash.new
        periods[p]["start"] = t2_pause
        periods[p]["end"] = t2_pause + (duration.quantity)*60
        for i in Integer(p+1)..Integer(p+p1-1)
          periods[i] = Hash.new
          periods[i]["start"] = periods[i-1]["end"]
          periods[i]["end"] = periods[i]["start"] + (duration.quantity)*60
        end
      end
      periods
  end

  def find_teachings(subperiod,gs)
    g = gs
    t = Array.new
    for i in 1..g.duration
      p = Period.find_by_year_and_subperiod(i,subperiod)
      ts = Teaching.find(:all, :include => [:curriculums, :teacher], :conditions => ["period_id = ?", p])
      ts.each do |te|
        t << te
      end
    end
    t
  end

  def find_teachings_by_curriculum(subperiod, curriculum, year,gs)
    g = gs
    t = Array.new
    p = Period.find_by_year_and_subperiod(year,subperiod)
    ts = Teaching.find(:all, :include => [:curriculums, :teacher], :conditions => ["period_id = ? AND curriculums.id = ?", p, curriculum])
    ts.each do |te|
      t << te
    end
    t
  end

  def process_file(graduate_course, year, subper, file_name)
    g = GraduateCourse.find(graduate_course)
    academic_year = year
    subperiod = subper
    timetables = Array.new
    for i in 1..g.duration
      p = Period.find_by_year_and_subperiod(i,subperiod)
      timetables << g.timetables.find(:first, :conditions => ["period_id = ? AND year = ?", p, academic_year])
    end
    File.open(file_name, "r") do |f|
      while line = f.gets
        if line != "UNSATISFIED PREFERENCES:"
          a = line.scan(/\w+/)
          teaching = Teaching.find(a[0].to_i)
          classroom = Classroom.find(a[2].to_i)
          periods = calculate_periods(g)
          y = teaching.period.year
          timetables[y-1].timetable_entries.create(:startTime => periods[a[4].to_i]["start"],
                                                   :endTime => periods[a[4].to_i]["end"],
                                                   :day => ((a[3].to_i) +1),
                                                   :classroom => classroom,
                                                   :teaching => teaching)
        end
      end
    end
  end
end
# pdf converter
 #def _index
#   @items = Item.find(:all)
# end
