class AddIsPublicToTimeTable < ActiveRecord::Migration
  def self.up
    add_column :timetables, :isPublic, :boolean
  end

  def self.down
    remove_column :timetables, :isPublic
  end
end
