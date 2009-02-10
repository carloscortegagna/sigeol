class CreateExpiryDates < ActiveRecord::Migration
  def self.up
    create_table :expiry_dates do |t|
      t.datetime :date
      t.integer :graduate_course_id
      t.timestamps
    end
  end

  def self.down
    drop_table :expiry_dates
  end
end
