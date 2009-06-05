# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090605145111) do

  create_table "academic_organizations", :force => true do |t|
    t.string   "name"
    t.integer  "number"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "academic_organizations", ["name"], :name => "index_academic_organizations_on_name", :unique => true
  add_index "academic_organizations", ["number"], :name => "index_academic_organizations_on_number", :unique => true

  create_table "addresses", :force => true do |t|
    t.string   "city"
    t.string   "telephone"
    t.string   "street"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "belongs", :force => true do |t|
    t.integer  "teaching_id",   :null => false
    t.integer  "curriculum_id", :null => false
    t.boolean  "isOptional"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "belongs", ["curriculum_id", "teaching_id"], :name => "index_belongs_on_curriculum_id_and_teaching_id", :unique => true
  add_index "belongs", ["teaching_id"], :name => "fk_belongs_teaching_id"

  create_table "boolean_constraints", :force => true do |t|
    t.boolean  "bool"
    t.string   "description"
    t.integer  "isHard"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "buildings", :force => true do |t|
    t.string   "name"
    t.integer  "address_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "buildings", ["address_id"], :name => "fk_buildings_address_id"
  add_index "buildings", ["name"], :name => "index_buildings_on_name", :unique => true

  create_table "capabilities", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "capabilities", ["name"], :name => "index_capabilities_on_name", :unique => true

  create_table "capabilities_users", :id => false, :force => true do |t|
    t.integer  "capability_id", :null => false
    t.integer  "user_id",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "capabilities_users", ["capability_id"], :name => "fk_capabilities_users_capability_id"
  add_index "capabilities_users", ["user_id", "capability_id"], :name => "index_capabilities_users_on_user_id_and_capability_id", :unique => true

  create_table "classrooms", :force => true do |t|
    t.string   "name"
    t.integer  "capacity"
    t.integer  "building_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "classrooms", ["building_id"], :name => "fk_classrooms_building_id"
  add_index "classrooms", ["name", "building_id"], :name => "index_classrooms_on_name_and_building_id", :unique => true

  create_table "classrooms_graduate_courses", :id => false, :force => true do |t|
    t.integer "graduate_course_id", :null => false
    t.integer "classroom_id",       :null => false
  end

  add_index "classrooms_graduate_courses", ["classroom_id"], :name => "fk_classrooms_graduate_courses_classroom_id"
  add_index "classrooms_graduate_courses", ["graduate_course_id", "classroom_id"], :name => "index_join", :unique => true

  create_table "constraints_owners", :force => true do |t|
    t.integer  "owner_id"
    t.string   "owner_type"
    t.integer  "constraint_id"
    t.string   "constraint_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "graduate_course_id"
  end

  create_table "curriculums", :force => true do |t|
    t.string   "name"
    t.integer  "graduate_course_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "curriculums", ["graduate_course_id"], :name => "fk_curriculums_graduate_course_id"
  add_index "curriculums", ["name", "graduate_course_id"], :name => "index_curriculums_on_name_and_graduate_course_id", :unique => true

  create_table "didactic_offices", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "expiry_dates", :force => true do |t|
    t.date     "date"
    t.integer  "graduate_course_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "period"
  end

  add_index "expiry_dates", ["graduate_course_id"], :name => "fk_expiry_dates_graduate_course_id"

  create_table "graduate_courses", :force => true do |t|
    t.string   "name"
    t.integer  "duration"
    t.integer  "academic_organization_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "graduate_courses", ["academic_organization_id"], :name => "fk_graduate_courses_academic_organization_id"
  add_index "graduate_courses", ["name"], :name => "index_graduate_courses_on_name", :unique => true

  create_table "graduate_courses_users", :id => false, :force => true do |t|
    t.integer "user_id",            :null => false
    t.integer "graduate_course_id", :null => false
  end

  add_index "graduate_courses_users", ["graduate_course_id"], :name => "fk_graduate_courses_users_graduate_course_id"
  add_index "graduate_courses_users", ["user_id"], :name => "fk_graduate_courses_users_user_id"

  create_table "periods", :force => true do |t|
    t.integer "subperiod"
    t.integer "year"
  end

  add_index "periods", ["subperiod", "year"], :name => "index_periods_on_subperiod_and_year", :unique => true

  create_table "quantity_constraints", :force => true do |t|
    t.integer  "quantity"
    t.string   "description"
    t.integer  "isHard"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "teachers", :force => true do |t|
    t.string   "name"
    t.string   "surname"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "teachings", :force => true do |t|
    t.string   "name"
    t.integer  "CFU"
    t.integer  "classHours"
    t.integer  "labHours"
    t.integer  "studentsNumber"
    t.integer  "teacher_id"
    t.integer  "period_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "teachings", ["period_id"], :name => "fk_teachings_period_id"
  add_index "teachings", ["teacher_id"], :name => "fk_teachings_teacher_id"

  create_table "temporal_constraints", :force => true do |t|
    t.integer  "day"
    t.time     "startHour"
    t.time     "endHour"
    t.string   "description"
    t.integer  "isHard"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "timetable_entries", :force => true do |t|
    t.time     "startTime"
    t.time     "endTime"
    t.integer  "day"
    t.integer  "timetable_id", :null => false
    t.integer  "teaching_id",  :null => false
    t.integer  "classroom_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "timetable_entries", ["classroom_id"], :name => "fk_timetable_entries_classroom_id"
  add_index "timetable_entries", ["startTime", "endTime", "day", "classroom_id", "timetable_id"], :name => "indice", :unique => true
  add_index "timetable_entries", ["teaching_id"], :name => "fk_timetable_entries_teaching_id"
  add_index "timetable_entries", ["timetable_id"], :name => "fk_timetable_entries_timetable_id"

  create_table "timetables", :force => true do |t|
    t.string   "year"
    t.integer  "period_id",          :null => false
    t.integer  "graduate_course_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "isPublic"
  end

  add_index "timetables", ["graduate_course_id"], :name => "fk_timetables_graduate_course_id"
  add_index "timetables", ["period_id", "year", "graduate_course_id"], :name => "index_timetables_on_period_id_and_year_and_graduate_course_id", :unique => true

  create_table "users", :force => true do |t|
    t.string   "mail"
    t.string   "password"
    t.integer  "specified_id"
    t.string   "specified_type"
    t.integer  "address_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "random"
    t.string   "digest"
  end

  add_index "users", ["address_id"], :name => "fk_users_address_id"
  add_index "users", ["mail"], :name => "index_users_on_mail", :unique => true
  add_index "users", ["specified_id", "specified_type"], :name => "index_users_on_specified_id_and_specified_type", :unique => true

end
