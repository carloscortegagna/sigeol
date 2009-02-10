class CreateDidacticOffices < ActiveRecord::Migration
  def self.up
    create_table :didactic_offices do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :didactic_offices
  end
end
