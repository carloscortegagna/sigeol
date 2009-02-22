class PopulateCapabilityWithManageGraduateCourse < ActiveRecord::Migration
  def self.up
    Capability.create :name => "Manage graduate courses"
  end

  def self.down
    Capability.destroy(Capability.find_by_name("Manage graduate courses").id)
  end
end
