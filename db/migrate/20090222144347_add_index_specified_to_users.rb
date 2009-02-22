class AddIndexSpecifiedToUsers < ActiveRecord::Migration
  def self.up
   add_index(:users,[:specified_id,:specified_type],:unique=>true)
  end

  def self.down
    remove_index(:users,[:specified_id,:specified_type])
  end
end
