class CreateConstraintsowners < ActiveRecord::Migration
  def self.up
    create_table :constraintsowners do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :constraintsowners
  end
end
