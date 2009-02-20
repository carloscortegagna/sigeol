class UniqueConstraint < ActiveRecord::Migration
  def self.up
   add_index(:graduate_courses, :name, :unique => true)
   add_index(:academic_organizations, :name, :unique => true)
   add_index(:academic_organizations, :number, :unique => true)
   add_index(:timetables, [:period_id,:year,:graduate_course_id], :unique => true)
   add_index(:periods, [:subperiod,:year], :unique => true)
   add_index(:timetable_entries,[:startTime,:endTime,:day,:classroom_id,:timetable_id], :unique => true)
   add_index(:users,:mail,:unique => true)
   add_index(:buildings,:name, :unique => true)
   add_index(:classrooms,[:name,:building_id], :unique => true)
   add_index(:capabilities,:name, :unique => true)
   add_index(:belongs,[:curriculum_id,:teaching_id],:unique=>true)
  end

  def self.down
  end
end
