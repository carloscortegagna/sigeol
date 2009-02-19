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

ActiveRecord::Schema.define(:version => 20090218173721) do

  create_table "academic_organizations", :force => true do |t|
    t.string  "name"
    t.integer "number"
    t.integer "created_at", :limit => 2000000000
    t.integer "updated_at", :limit => 2000000000
  end

  create_table "addresses", :force => true do |t|
    t.string  "city"
    t.string  "telephone"
    t.string  "street"
    t.integer "created_at", :limit => 2000000000
    t.integer "updated_at", :limit => 2000000000
  end

  create_table "belongs", :force => true do |t|
    t.integer "teaching_id"
    t.integer "curriculum_id"
    t.integer "isOptional",    :limit => 1
    t.integer "created_at",    :limit => 2000000000
    t.integer "updated_at",    :limit => 2000000000
  end

  create_table "boolean_constraints", :force => true do |t|
    t.integer "bool",       :limit => 1
    t.integer "created_at", :limit => 2000000000
    t.integer "updated_at", :limit => 2000000000
  end

  create_table "buildings", :force => true do |t|
    t.string  "name"
    t.integer "address_id"
    t.integer "created_at", :limit => 2000000000
    t.integer "updated_at", :limit => 2000000000
  end

  create_table "capabilities", :force => true do |t|
    t.string  "name"
    t.integer "created_at", :limit => 2000000000
    t.integer "updated_at", :limit => 2000000000
  end

  create_table "capabilities_users", :force => true do |t|
    t.integer "capability_id"
    t.integer "user_id"
    t.integer "created_at",    :limit => 2000000000
    t.integer "updated_at",    :limit => 2000000000
  end

  create_table "classrooms", :force => true do |t|
    t.string  "name"
    t.integer "capacity"
    t.integer "building_id"
    t.integer "created_at",  :limit => 2000000000
    t.integer "updated_at",  :limit => 2000000000
  end

  create_table "constraints_owners", :force => true do |t|
    t.string  "description"
    t.integer "owner_id"
    t.string  "owner_type"
    t.integer "constraint_id"
    t.string  "constraint_type"
    t.integer "created_at",      :limit => 2000000000
    t.integer "updated_at",      :limit => 2000000000
  end

  create_table "curriculums", :force => true do |t|
    t.string  "name"
    t.integer "graduate_course_id"
    t.integer "created_at",         :limit => 2000000000
    t.integer "updated_at",         :limit => 2000000000
  end

  create_table "didactic_offices", :force => true do |t|
    t.integer "created_at", :limit => 2000000000
    t.integer "updated_at", :limit => 2000000000
  end

  create_table "expiry_dates", :force => true do |t|
    t.string  "date"
    t.integer "graduate_course_id"
    t.integer "created_at",         :limit => 2000000000
    t.integer "updated_at",         :limit => 2000000000
  end

  create_table "graduate_courses", :force => true do |t|
    t.string  "name"
    t.integer "duration"
    t.integer "academic_organization_id"
    t.integer "created_at",               :limit => 2000000000
    t.integer "updated_at",               :limit => 2000000000
  end

  create_table "graduate_courses_users", :id => false, :force => true do |t|
    t.integer "user_id"
    t.integer "graduate_course_id"
  end

  create_table "periods", :force => true do |t|
    t.integer "subperiod"
    t.integer "year"
  end

  create_table "quantity_constraints", :force => true do |t|
    t.integer "quantity"
    t.integer "created_at", :limit => 2000000000
    t.integer "updated_at", :limit => 2000000000
  end

  create_table "sessions", :force => true do |t|
    t.string  "session_id"
    t.string  "data",       :limit => 2000000000
    t.integer "created_at", :limit => 2000000000
    t.integer "updated_at", :limit => 2000000000
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "teachers", :force => true do |t|
    t.string  "name"
    t.string  "surname"
    t.integer "created_at", :limit => 2000000000
    t.integer "updated_at", :limit => 2000000000
  end

  create_table "teachings", :force => true do |t|
    t.string  "name"
    t.integer "CFU"
    t.integer "classHours"
    t.integer "labHours"
    t.integer "studentsNumber"
    t.integer "teacher_id"
    t.integer "period_id"
    t.integer "created_at",     :limit => 2000000000
    t.integer "updated_at",     :limit => 2000000000
  end

  create_table "temporal_constraints", :force => true do |t|
    t.integer "day"
    t.integer "startHour",  :limit => 2000000000
    t.integer "endHour",    :limit => 2000000000
    t.integer "created_at", :limit => 2000000000
    t.integer "updated_at", :limit => 2000000000
  end

  create_table "timetable_entries", :force => true do |t|
    t.integer "startTime",    :limit => 2000000000
    t.integer "endTime",      :limit => 2000000000
    t.string  "day"
    t.integer "timetable_id"
    t.integer "teaching_id"
    t.integer "created_at",   :limit => 2000000000
    t.integer "updated_at",   :limit => 2000000000
  end

  create_table "timetables", :force => true do |t|
    t.string  "year"
    t.integer "period_id"
    t.integer "graduate_course_id"
    t.integer "created_at",         :limit => 2000000000
    t.integer "updated_at",         :limit => 2000000000
  end

  create_table "users", :force => true do |t|
    t.string  "mail"
    t.string  "password"
    t.integer "specified_id"
    t.string  "specified_type"
    t.integer "address_id"
    t.integer "created_at",     :limit => 2000000000
    t.integer "updated_at",     :limit => 2000000000
    t.integer "random"
    t.string  "digest"
  end

end
