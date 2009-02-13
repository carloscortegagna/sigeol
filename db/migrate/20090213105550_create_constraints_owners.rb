class CreateConstraintsOwners < ActiveRecord::Migration
  def self.up
    create_table :constraints_owners do |t|
      t.string :description
      t.references :owner, :polymorphic => true
      t.references :constraint, :polymorphic => true

      t.timestamps
    end
  end

  def self.down
    drop_table :constraints_owners
  end
end
