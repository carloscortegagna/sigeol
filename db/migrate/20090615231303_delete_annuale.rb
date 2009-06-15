class DeleteAnnuale < ActiveRecord::Migration
  def self.up
    (AcademicOrganization.find_by_name('Annuale')).destroy
  end

  def self.down
  end
end
