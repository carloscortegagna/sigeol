class CreatePeriods < ActiveRecord::Migration
  def self.up
    create_table :periods do |t|
      t.integer :subperiod
      t.integer :year
    end
  add_index(:periods, [:subperiod,:year], :unique => true)
  end

  def self.down
    remove_index :periods, :column=>[:subperiod,:year]
    drop_table :periods
  end
end
