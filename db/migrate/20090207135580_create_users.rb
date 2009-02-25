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
    add_index(:users,:mail,:unique => true)
    add_index(:users,[:specified_id,:specified_type],:unique=>true)
  end
  def self.down
    remove_index(:users,[:specified_id,:specified_type])
    remove_index :users,:column=>:mail
    drop_table :users
  end
end
