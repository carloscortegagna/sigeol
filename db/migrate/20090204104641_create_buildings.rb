class CreateBuildings < ActiveRecord::Migration
  def self.up
    create_table :buildings do |t|
      t.string :name
      t.integer :address_id
      t.timestamps
      end
      add_index(:buildings,:name, :unique => true)
  end

  def self.down
    remove_index :buildings,:column=>:name
    drop_table :buildings
  end
end
