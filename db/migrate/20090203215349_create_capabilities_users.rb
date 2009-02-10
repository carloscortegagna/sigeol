class CreateCapabilitiesUsers < ActiveRecord::Migration
  def self.up
   create_table :capabilities_users do |t|
     t.integer :capability_id
     t.integer :user_id
     t.timestamps
    end
  end

  def self.down
    drop_table :capabilities_users
  end
end
