class AddColumnToExpiryDate < ActiveRecord::Migration
  def self.up
  add_column :expiry_dates, :period, :integer
  change_column :expiry_dates, :date, :date
  end

  def self.down
    remove_column :expiry_dates, :period
  end
end
