class CreateBuildings < ActiveRecord::Migration
  def self.up
    create_table :buildings do |t|
      t.string :name
      t.integer :address_id
      t.timestamps
      end
  end

  def self.down
    drop_table :buildings
  end
end