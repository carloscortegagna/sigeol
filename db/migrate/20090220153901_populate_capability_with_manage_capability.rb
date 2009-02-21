class PopulateCapabilityWithManageCapability < ActiveRecord::Migration
  def self.up
    Capability.create :name => "Manage capabilities"
  end

  def self.down
    Capability.destroy(Capability.find_by_name("Manage capabilities").id)
  end
end
