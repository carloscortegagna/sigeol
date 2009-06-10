class AddLabToClassroom < ActiveRecord::Migration
  def self.up
    add_column :classrooms, :lab, :boolean
  end

  def self.down
    remove_column :classrooms, :lab
  end
end
