class CreateBooleanConstraints < ActiveRecord::Migration
  def self.up
    create_table :boolean_constraints do |t|
      t.boolean :bool
      t.timestamps
    end
  end

  def self.down
    drop_table :boolean_constraints
  end
end
