class CreateClassrooms < ActiveRecord::Migration
  def self.up
    create_table :classrooms do |t|
      t.string :name
      t.integer :capacity
      t.integer :building_id, :null=>false
      t.timestamps
    end
    add_index(:classrooms,[:name,:building_id], :unique => true)
  end

  def self.down
    remove_index :classrooms,:column=>[:name,:building_id]
    drop_table :classrooms
  end
end
