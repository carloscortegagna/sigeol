class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :mail
      t.string :password
      t.integer :specified_id
      t.string :specified_type
      t.integer :address_id
      t.timestamps
    end
  end
  def self.down
    drop_table :users
  end
end
