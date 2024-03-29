class IntegrityConstraints < ActiveRecord::Migration
  extend MigrationHelper  # see lib/migration_helpers.rb
  def self.up
    fk :teachings, :period_id, :periods
    #vincoli sulla tabella expiry_dates
    fk :expiry_dates,:graduate_course_id,:graduate_courses
    #vincoli sulla tabella graduate_courses
    fk :graduate_courses,:academic_organization_id,:academic_organizations
   #vincoli sulla tabella belongs
    fk :belongs,:curriculum_id,:curriculums
    fk :belongs,:teaching_id,:teachings
    #vincoli sulla tabella curriculums
    fk :curriculums,:graduate_course_id,:graduate_courses
    #vincoli sulla tabella classrooms
    fk :classrooms,:building_id,:buildings
    #vincoli sulla tabella timetables
    fk :timetables,:period_id,:periods
    fk :timetables,:graduate_course_id,:graduate_courses
    #vincoli sulla tabella timetables_entries
    fk :timetable_entries,:timetable_id,:timetables
    #vincoli sulla tabella capabilities_users
    fk :capabilities_users,:user_id,:users,2
    fk :capabilities_users,:capability_id,:capabilities,2
     #vincoli sulla tabella buildings
    fk :buildings,:address_id,:addresses,1
     #vincoli sulla tabella users
    fk :users,:address_id,:addresses,1
    fk :teachings, :teacher_id, :teachers,1

  end

  def self.down
    drop_fk :teachings, :period_id
    #vincoli sulla tabella expiry_dates
    drop_fk :expiry_dates,:graduate_course_id
    #vincoli sulla tabella graduate_courses
    drop_fk :graduate_courses,:academic_organization_id
    #vincoli sulla tabella belongs
    drop_fk :belongs,:curriculum_id
    drop_fk :belongs,:teaching_id
    #vincoli sulla tabella curriculums
    drop_fk :curriculums,:graduate_course_id
    #vincoli sulla tabella classrooms
    drop_fk :classrooms,:building_id
    #vincoli sulla tabella timetables
    drop_fk :timetables,:period_id
    drop_fk :timetables,:graduate_course_id
    #vincoli sulla tabella timetables_entries
    drop_fk :timetable_entries,:timetable_id
    #vincoli sulla tabella capabilities_users
    drop_fk :capabilities_users,:user_id
    drop_fk :capabilities_users,:capability_id
    drop_fk :buildings,:address_id
    #vincoli sulla tabella users
    drop_fk :users,:address_id
    drop_fk :teachings,:teacher_id

  end
end
