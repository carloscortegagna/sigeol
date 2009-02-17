class AddRandomDigestToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :random, :integer
    add_column :users, :digest, :string
  end

  def self.down
    remove_column :users, :digest
    remove_column :users, :random
  end
end
