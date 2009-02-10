class CreatePeriods < ActiveRecord::Migration
  def self.up
    create_table :periods do |t|
      t.integer :subperiod
      t.integer :year
    end
  end

  def self.down
    drop_table :periods
  end
end
