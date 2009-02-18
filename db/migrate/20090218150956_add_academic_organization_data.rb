class AddAcademicOrganizationData < ActiveRecord::Migration
  def self.up
    AcademicOrganization.delete_all
    AcademicOrganization.create(:id => 1, :name => 'Annuale', :number => 1)
    AcademicOrganization.create(:id => 2, :name => 'Semestri', :number => 2)
    AcademicOrganization.create(:id => 3, :name => 'Trimestri', :number => 3)
    AcademicOrganization.create(:id => 4, :name => 'Quadrimestri', :number => 4)
  end
  
  def self.down
    AcademicOrganization.delete_all
  end
end
