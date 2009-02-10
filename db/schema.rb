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

ActiveRecord::Schema.define(:version => 20090210124634) do

  create_table "academic_organizations", :force => true do |t|
    t.string  "name"
    t.integer "number", :limit => 11
  end

  create_table "addresses", :force => true do |t|
    t.string "city"
    t.string "telephone"
    t.string "street"
  end

  create_table "belongs", :force => true do |t|
    t.integer  "teaching_id",   :limit => 11
    t.integer  "curriculum_id", :limit => 11
    t.boolean  "isOptional"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "buildings", :force => true do |t|
    t.string  "name"
    t.integer "address_id", :limit => 11
  end

  create_table "capabilities", :force => true do |t|
    t.string "name"
  end

  create_table "capabilities_users", :force => true do |t|
    t.integer "capability_id", :limit => 11
    t.integer "user_id",       :limit => 11
  end

  create_table "classrooms", :force => true do |t|
    t.string   "name"
    t.integer  "capacity",    :limit => 11
    t.integer  "building_id", :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "curriculums", :force => true do |t|
    t.string   "name"
    t.integer  "graduate_course_id", :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "didactic_offices", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "expiry_dates", :force => true do |t|
    t.datetime "date"
    t.integer  "graduate_course_id", :limit => 11
  end

  create_table "graduate_courses", :force => true do |t|
    t.string  "name"
    t.integer "duration",                 :limit => 11
    t.integer "academic_organization_id", :limit => 11
  end

  create_table "periods", :force => true do |t|
    t.integer "subperiod", :limit => 11
    t.integer "year",      :limit => 11
  end

  create_table "teachers", :force => true do |t|
    t.string   "name"
    t.string   "surname"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "teachings", :force => true do |t|
    t.string  "name"
    t.integer "CFU",            :limit => 11
    t.integer "classHours",     :limit => 11
    t.integer "labHours",       :limit => 11
    t.integer "studentsNumber", :limit => 11
    t.integer "teacher_id",     :limit => 11
    t.integer "period_id",      :limit => 11
  end

  create_table "timetable_entries", :force => true do |t|
    t.time     "startTime"
    t.time     "endTime"
    t.string   "day"
    t.integer  "timetable_id", :limit => 11
    t.integer  "teaching_id",  :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "timetables", :force => true do |t|
    t.string   "year"
    t.integer  "period_id",          :limit => 11
    t.integer  "graduate_course_id", :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "mail"
    t.string   "password"
    t.integer  "specified_id",   :limit => 11
    t.string   "specified_type"
    t.integer  "address_id",     :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
