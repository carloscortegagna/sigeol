class RemoveDescriptionsToConstraintsOwner < ActiveRecord::Migration
  def self.up
    remove_column :constraints_owners ,:description
  end

  def self.down
  end
end
