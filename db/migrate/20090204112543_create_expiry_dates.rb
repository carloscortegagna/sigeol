class CreateExpiryDates < ActiveRecord::Migration
  def self.up
    create_table :expiry_dates do |t|
      t.string :date
      t.integer :graduate_course_id, :null=>false
      t.timestamps
    end
  end

  def self.down
    drop_table :expiry_dates
  end
end
