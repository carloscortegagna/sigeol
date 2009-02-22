class IntegrityConstraints < ActiveRecord::Migration
  extend MigrationHelper  # see lib/migration_helpers.rb
  def self.up
    #vincoli sulla tabella periods
    constraint_on_delete("periods","period_id","teachings",0)
    constraint_on_delete("teachings","period_id","timetables",0)
    #vincoli sulla tabella buildings
    constraint_on_create("buildings","address_id","addresses",1)
    constraint_on_update("buildings","address_id","addresses",1)
    constraint_on_delete("buildings","building_id","classrooms",0)
    #vincoli sulla tabella adresses
    constraint_on_delete("addresses","address_id","users",1)
    constraint_on_delete("addresses","address_id","buildings",1)
    #vincoli sulla tabella expiry_dates
    constraint_on_create("expiry_dates","graduate_course_id","graduate_courses",0)
    constraint_on_update("expiry_dates","graduate_course_id","graduate_courses",0)
    #vincoli sulla tabella graduate_courses
    constraint_on_create("graduate_courses","academic_organization_id","academic_organizations",0)
    constraint_on_update("graduate_courses","academic_organization_id","academic_organizations",0)
    constraint_on_delete("graduate_courses","graduate_course_id","curriculums",0)
    constraint_on_delete("graduate_courses","graduate_course_id","expiry_dates",0)
    constraint_on_delete("graduate_courses","graduate_course_id","timetables",0)
    #vincoli sulla tabella academic_organizations
    constraint_on_delete("academic_organizations","academic_organization_id","graduate_courses",0)
    #vincoli sulla tabella teachers
    constraint_on_delete("teachers","teacher_id","teachings",1)
    #vincoli sulla tabella teachings
    constraint_on_create("teachings","period_id","periods",1)
    constraint_on_update("teachings","period_id","periods",1)
    constraint_on_create("teachings","teacher_id","teachers",1)
    constraint_on_update("teachings","teacher_id","teachers",1)
    constraint_on_delete("teachings","teaching_id","belongs",0)
    constraint_on_delete("teachings","teaching_id","timetable_entries",0)
    #vincoli sulla tabella users
    constraint_on_create("users","address_id","addresses",1)
    constraint_on_update("users","address_id","addresses",1)
    constraint_on_delete("users","user_id","capabilities_users",0)

    #vincoli sulla tabella capabilities
    constraint_on_delete("capabilities","capability_id","capabilities_users",0)
    #vincoli sulla tabella belongs
    constraint_on_create("belongs","curriculum_id","curriculums",0)
    constraint_on_create("belongs","teaching_id","teachings",0)
    constraint_on_update("belongs","curriculum_id","curriculums",0)
    constraint_on_update("belongs","teaching_id","teachings",0)
    #vincoli sulla tabella curriculums
    constraint_on_create("curriculums","graduate_course_id","graduate_courses",0)
    constraint_on_update("curriculums","graduate_course_id","graduate_courses",0)
    constraint_on_delete("curriculums","curriculum_id","belongs",0)
    #vincoli sulla tabella classrooms
    constraint_on_create("classrooms","building_id","buildings",0)
    constraint_on_update("classrooms","building_id","buildings",0)
    constraint_on_delete("classrooms","classroom_id","timetable_entries",0)
    #vincoli sulla tabella timetables
    constraint_on_delete("timetables","timetable_id","timetable_entries",0)
    constraint_on_create("timetables","period_id","periods",0)
    constraint_on_update("timetables","period_id","periods",0)
    constraint_on_create("timetables","graduate_course_id","graduate_courses",0)
    constraint_on_update("timetables","graduate_course_id","graduate_courses",0)
    #vincoli sulla tabella timetables_entries
    constraint_on_create("timetable_entries","period_id","periods",0)
    constraint_on_update("timetable_entries","period_id","periods",0)
    constraint_on_create("timetable_entries","classroom_id","classrooms",0)
    constraint_on_update("timetable_entries","classroom_id","classrooms",0)
    constraint_on_create("timetable_entries","teaching_id","teachings",0)
    constraint_on_update("timetable_entries","teaching_id","teachings",0)
    #vincoli sulla tabella capabilities_users
    constraint_on_create("capabilities_users","user_id","users",0)
    constraint_on_update("capabilities_users","user_id","users",0)
    constraint_on_create("capabilities_users","capability_id","capabilities",0)
    constraint_on_update("capabilities_users","capability_id","capabilities",0)
  end

  def self.down
    #vincoli sulla tabella periods
    cancel_delete("periods","period_id")
    cancel_delete("teachings","period_id")
    #vincoli sulla tabella buildings
    cancel_create("buildings","address_id")
    cancel_update("buildings","address_id")
    cancel_delete("buildings","building_id")
    #vincoli sulla tabella adresses
    cancel_delete("addresses","address_id")
    cancel_delete("addresses","address_id")
    #vincoli sulla tabella expiry_dates
    cancel_create("expiry_dates","graduate_course_id")
    cancel_update("expiry_dates","graduate_course_id")
    #vincoli sulla tabella graduate_courses
    cancel_create("graduate_courses","academic_organization_id")
    cancel_update("graduate_courses","academic_organization_id")
    cancel_delete("graduate_courses","graduate_course_id")
    cancel_delete("graduate_courses","graduate_course_id")
    cancel_delete("graduate_courses","graduate_course_id")
    #vincoli sulla tabella academic_organizations
    cancel_delete("academic_organizations","academic_organization_id")
    #vincoli sulla tabella teachers
    cancel_delete("teachers","teacher_id")
    #vincoli sulla tabella teachings
    cancel_create("teachings","period_id")
    cancel_update("teachings","period_id")
    cancel_create("teachings","teacher_id")
    cancel_update("teachings","teacher_id")
    cancel_delete("teachings","teaching_id")
    cancel_delete("teachings","teaching_id")
    #vincoli sulla tabella users
    cancel_create("users","address_id")
    cancel_update("users","address_id")
    cancel_delete("users","user_id")

    #vincoli sulla tabella capabilities
    cancel_delete("capabilities","capability_id")
    #vincoli sulla tabella belongs
    cancel_create("belongs","curriculum_id")
    cancel_create("belongs","teaching_id")
    cancel_update("belongs","curriculum_id")
    cancel_update("belongs","teaching_id")
    #vincoli sulla tabella curriculums
    cancel_create("curriculums","graduate_course_id")
    cancel_update("curriculums","graduate_course_id")
    cancel_delete("curriculums","curriculum_id")
    #vincoli sulla tabella classrooms
    cancel_create("classrooms","building_id")
    cancel_update("classrooms","building_id")
    cancel_delete("classrooms","classroom_id")
    #vincoli sulla tabella timetables
    cancel_delete("timetables","timetable_id")
    cancel_create("timetables","period_id")
    cancel_update("timetables","period_id")
    cancel_create("timetables","graduate_course_id")
    cancel_update("timetables","graduate_course_id")
    #vincoli sulla tabella timetables_entries
    cancel_create("timetable_entries","period_id")
    cancel_update("timetable_entries","period_id")
    cancel_create("timetable_entries","classroom_id")
    cancel_update("timetable_entries","classroom_id")
    cancel_create("timetable_entries","teaching_id")
    cancel_update("timetable_entries","teaching_id")
    #vincoli sulla tabella capabilities_users
    cancel_create("capabilities_users","user_id")
    cancel_update("capabilities_users","user_id")
    cancel_create("capabilities_users","capability_id")
    cancel_update("capabilities_users","capability_id")
  end
end
