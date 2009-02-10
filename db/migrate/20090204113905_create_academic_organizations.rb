class CreateAcademicOrganizations < ActiveRecord::Migration
  def self.up
    create_table :academic_organizations do |t|
      t.string :name
      t.integer :number
      t.timestamps
    end
  end

  def self.down
    drop_table :academic_organizations
  end
end
