#=QuiXoft - Progetto SIGEOL
#NOME FILE:: graduate_course.rb
#AUTORE:: Grosselle Alessandro
#DATA CREAZIONE:: 16/02/2009
#REGISTRO DELLE MODIFICHE::
# 27/04/2009 Approvazione del responsabile
#
# 10/03/2009 Aggiunta dell'associazione polimorfa has_many :constraints
#
# 20/02/2009 Aggiunta dell'associazione has_and_belongs_to_many :users e has_and_belongs_to_many :classrooms
#
# 17/02/2009 Aggiunta delle validazioni
#
# 16/02/2009 Prima stesura
#
#Rappresentazione di un corso di laurea.

class GraduateCourse < ActiveRecord::Base
  include ApplicationHelper

  has_many :constraints, :dependent=> :destroy
  has_many :constraints_owners
  has_many :expiry_dates, :dependent => :destroy
  belongs_to :academic_organization
  has_many :timetables, :dependent => :destroy
  has_many :curriculums, :dependent => :destroy
  has_and_belongs_to_many :users, :uniq => true
  has_and_belongs_to_many :classrooms, :uniq => true
  
  #validazioni :name
  validates_uniqueness_of :name,
                          :message=>"Il corso è già presente"
  validates_presence_of :name,
                        :message=>"Il nome non deve essere vuoto"
  validates_length_of :name,
                       :maximum=> 50,
                       :message=>"Il nome è troppo lungo"
  validates_format_of :name,
                       :with => /^[a-zA-Zàòèéùì\s]*$/,
                       :message => "Si accettano solo caratteri alfabetici"
  validates_presence_of :academic_organization_id,
                         :message => "Deve essere associata ad un'organizzazione accademica"

  #validazioni :duration
  validates_numericality_of :duration,
                            :only_integer =>true,
                            :greater_than_or_equal_to =>1,
                            :less_than_or_equal_to =>6,
                            :message=>"Attenzione il numero deve essere compreso tra 1 e 6"

  validates_presence_of  :duration,
                         :message=>"La durata non deve essere vuota"

  #Override del metodo della super classe per impostare il primo carattere del nome in maiusculo
  #ed i rimanenti in minuscolo, prima delle validazioni.
  def before_validation
   self.name=first_upper(self.name)
  end

  def timetables_in_generation?
    total_subperiod = self.academic_organization.number
    for k in 1..total_subperiod
      date = self.expiry_dates.find_by_period(k)
      for i in 1..self.duration
        p = Period.find_by_year_and_subperiod(i,k)
        t = self.timetables.find(:all, :conditions => ["period_id = ?", p.id])
        t.each do |timet|
          if timet.timetable_entries.empty?
        unless date
          return false
        end
            if date.date <= DateTime.now
              return true
            end
          end
        end
      end
    end
    return false
  end

  def timetables_in_schedulation?
    total_subperiod = self.academic_organization.number
    for k in 1..total_subperiod
      date = self.expiry_dates.find_by_period(k)
      for i in 1..self.duration
        p = Period.find_by_year_and_subperiod(i,k)
        t = self.timetables.find(:all, :conditions => ["period_id = ?", p.id])
        t.each do |timet|
          if timet.timetable_entries.empty?
          unless date
            return false
          end
            if date.date > DateTime.now
              return true
            end
          end
        end
      end
    end
    return false
  end

  def timetables_in_schedulation_specific?(subperiod, academic_year)
    date = self.expiry_dates.find_by_period(subperiod)
    for i in 1..self.duration
      p = Period.find_by_year_and_subperiod(i,subperiod)
      t = self.timetables.find(:first, :conditions => ["period_id = ? AND year = ?", p.id, academic_year])
      if t && t.timetable_entries.empty?
      unless date
          return false
      end
        if date.date > DateTime.now
          return true
        end
      end
    end
    return false
  end

  def timetables_in_generation_specific?(subperiod, academic_year)
    date = self.expiry_dates.find_by_period(subperiod)
    for i in 1..self.duration
      p = Period.find_by_year_and_subperiod(i,subperiod)
      t = self.timetables.find(:first, :conditions => ["period_id = ? AND year = ?", p.id, academic_year])
      if t && t.timetable_entries.empty?
        unless date
          return false
        end
        if date.date <= DateTime.now
          return true
        end
      end
    end
    return false
  end
 end