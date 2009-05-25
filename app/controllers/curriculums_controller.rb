#=QuiXoft - Progetto ”SIGEOL”
#NOME FILE:: buildings_controller.rb
#VERSIONE:: 1.0.0
#AUTORE:: ???
#DATA CREAZIONE:: ???
#REGISTRO DELLE MODIFICHE::
# 25/05/2009 Aggiunte su create e update le istruzioni necessarie per renderizzare il contenuto con js:
#  format.js{render(:update) {|page| page.redirect_to :controller=>"graduate_course",:action => 'administration'}}

class CurriculumsController < ApplicationController
  skip_before_filter :login_required, :only => :show
  before_filter :manage_graduate_courses_required, :only => [:new, :create, :edit, :update, :destroy,
                                                             :edit_teachings, :update_teachings]

  before_filter :same_graduate_course_required, :only => [:edit, :update, :edit_teachings, :update_teachings]

  # GET /curriculums/1
  # GET /curriculums/1.xml
  def show
    @curriculum = Curriculum.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @curriculum.to_xml(:except =>[:created_at, :updated_at, :id, :graduate_course_id]) } # show xml
    end
  end

  # GET /curriculums/new
  # GET /curriculums/new.xml
  def new
    @curriculum = Curriculum.new
    @graduate_courses = @current_user.graduate_courses
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /curriculums/1/edit
  def edit
    @curriculum = Curriculum.find(params[:id])
    @graduate_courses = @current_user.graduate_courses
  end

  # POST /curriculums
  # POST /curriculums.xml
  def create
    @curriculum = Curriculum.new(params[:curriculum])
    respond_to do |format|
      if @curriculum.save
        flash[:notice] = 'Curriculum creato con successo'
        format.html { redirect_to :controller => 'graduate_courses', :action => 'administration'}
        format.js{render(:update) {|page| page.redirect_to :controller => 'graduate_courses', :action => 'administration'}}
      else
        @graduate_courses = @current_user.graduate_courses
        format.html { render :action => "new" }
        format.js{}
        end
    end
  end

  # PUT /curriculums/1
  # PUT /curriculums/1.xml
  def update
    @curriculum = Curriculum.find(params[:id])

    respond_to do |format|
      if @curriculum.update_attributes(params[:curriculum])
        flash[:notice] = 'Curriculum modificato con successo'
        format.html { redirect_to :controller => 'graduate_courses', :action => 'administration' }
        format.js{render(:update) {|page| page.redirect_to :controller => 'graduate_courses', :action => 'administration'}}
      else
        @graduate_courses = @current_user.graduate_courses
        format.html { render :action => "edit" }
        format.js{ render :action => "create.js.rjs" }
      end
    end
  end

  def edit_teachings
    @curriculum = Curriculum.find(params[:id])
    id = @curriculum.graduate_course.id
    @teachings = Teaching.find(:all, :include => {:curriculums => :graduate_course},
                                  :conditions => ["graduate_courses.id = ?", id])
    @teachings = @teachings - @curriculum.teachings
  end

  def update_teachings
    if request.put?
      @curriculum = Curriculum.find(params[:id])
      teaching = Teaching.find params[:teaching_id]
      optional = false
      optional = true if params[:isOptional]
      @curriculum.belongs.create(:teaching => teaching, :isOptional => optional)
      flash[:notice] = "Insegnamento aggiunto correttamente"
      redirect_to administration_graduate_courses_url
    end
    if request.delete?
      @curriculum = Curriculum.find(params[:id])
      teaching = @curriculum.teachings.find(params[:t_to_remove])
      if (teaching)
        @curriculum.teachings.delete(teaching)
        flash[:notice] = "Insegnamento eliminato con successo"
      else
        flash[:error] = "Insegnamento non presente nel curriculum"
      end
      redirect_to administration_graduate_courses_url
    end
  end

  # DELETE /curriculums/1
  # DELETE /curriculums/1.xml
  def destroy
    @curriculum = Curriculum.find(params[:id])
    @curriculum.destroy

    respond_to do |format|
      format.html { redirect_to :controller => 'graduate_courses', :action => 'administration' }
    end
  end

  private

  def same_graduate_course_required
    ids = @current_user.graduate_course_ids
    curriculum = Curriculum.find(params[:id])
    unless (ids.include?(curriculum.graduate_course_id))
      flash[:error] = "Questo curriculum non appartiene a nessun tuo corso di laurea"
      redirect_to timetables_url
    end
  end
end