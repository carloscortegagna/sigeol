class CreateAcademicOrganizations < ActiveRecord::Migration
  def self.up
    create_table :academic_organizations do |t|
      t.string :name
      t.integer :number
      t.timestamps
    end
    add_index(:academic_organizations, :name, :unique => true)
    add_index(:academic_organizations, :number, :unique => true)
  end

  def self.down
    remove_index :academic_organizations, :column=>:name
    remove_index :academic_organizations, :column=>:number
    drop_table :academic_organizations
  end
end
