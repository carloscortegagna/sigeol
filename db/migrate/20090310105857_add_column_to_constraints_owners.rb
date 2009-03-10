class AddColumnToConstraintsOwners < ActiveRecord::Migration
  def self.up
   add_column :constraints_owners, :graduate_course_id, :integer
  end

  def self.down
    remove_column :constraints_owners, :graduate_course_id
  end
end
