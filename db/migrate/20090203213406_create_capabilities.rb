class CreateCapabilities < ActiveRecord::Migration
  def self.up
    create_table :capabilities do |t|
      t.string :name
      t.timestamps
      end
      add_index(:capabilities,:name, :unique => true)
  end

  def self.down
    remove_index :capabilities,:column=>:name
    drop_table :capabilities
  end
end
