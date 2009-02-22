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
   remove_index :graduate_courses, :column=>:name
   remove_index :academic_organizations, :column=>:name
   remove_index :academic_organizations, :column=>:number
   remove_index :timetables, :column=>[:period_id,:year,:graduate_course_id]
   remove_index :periods, :column=>[:subperiod,:year]
   remove_index :timetable_entries,:column=>[:startTime,:endTime,:day,:classroom_id,:timetable_id]
   remove_index :users,:column=>:mail
   remove_index :buildings,:column=>:name
   remove_index :classrooms,:column=>[:name,:building_id]
   remove_index :capabilities,:column=>:name
   remove_index :belongs,:column=>[:curriculum_id,:teaching_id]
  end
end
