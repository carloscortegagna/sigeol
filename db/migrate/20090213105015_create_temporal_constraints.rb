class CreateTemporalConstraints < ActiveRecord::Migration
  def self.up
    create_table :temporal_constraints do |t|
      t.integer :day
      t.time :startHour
      t.time :endHour
      t.timestamps
    end
  end

  def self.down
    drop_table :temporal_constraints
  end
end
