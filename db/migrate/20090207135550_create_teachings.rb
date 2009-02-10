class CreateTeachings < ActiveRecord::Migration
  def self.up
   create_table :teachings do |t|
     t.string :name
     t.integer :CFU
     t.integer :classHours
     t.integer :labHours
     t.integer :studentsNumber
     t.integer :teacher_id
     t.integer :period_id
     t.timestamps
    end
  end

  def self.down
   drop_table :teachings
  end
end
