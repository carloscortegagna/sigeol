class CreateCapabilitiesUsers < ActiveRecord::Migration
  def self.up
   create_table :capabilities_users, :id => false do |t|
     t.integer :capability_id, :null=>false
     t.integer :user_id, :null=>false
     t.timestamps
    end
    add_index(:capabilities_users,[:user_id,:capability_id],:unique=>true)
  end

  def self.down
    remove_index(:capabilities_users,[:user_id,:capability_id])
    drop_table :capabilities_users
  end
end
