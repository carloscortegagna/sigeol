class AddIndexConstraintsUsers < ActiveRecord::Migration
  def self.up
     add_index(:capabilities_users,[:user_id,:capability_id],:unique=>true)
  end

  def self.down
     remove_index(:capabilities_users,[:user_id,:capability_id])
   end
end
