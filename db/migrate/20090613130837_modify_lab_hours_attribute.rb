class ModifyLabHoursAttribute < ActiveRecord::Migration
  def self.up
    remove_column :teachings, :labHours
    remove_column :teachings, :studentsNumber
    add_column :teachings, :labHours, :integer, :default => 0
    add_column :teachings, :studentsNumber, :integer, :default => 0
  end

  def self.down
        remove_column :teachings, :labHours
      remove_column :teachings, :studentsNumber, :default => 0
    end
end
