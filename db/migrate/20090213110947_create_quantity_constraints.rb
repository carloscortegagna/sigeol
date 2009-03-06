class CreateQuantityConstraints < ActiveRecord::Migration
  def self.up
    create_table :quantity_constraints do |t|
      t.integer :quantity
      t.string :description
      t.integer :isHard
      t.timestamps
    end
  end

  def self.down
    drop_table :quantity_constraints
  end
end
