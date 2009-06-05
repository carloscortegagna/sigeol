class PopulateCapabilitiesIta < ActiveRecord::Migration
def self.up
    Capability.create :name => "Gestione docenti"
    Capability.create :name => "Gestione insegnamenti"
    Capability.create :name => "Gestione aule"
    Capability.create :name => "Gestione edifici"
    Capability.create :name => "Gestione schemi d'orario"
    Capability.create :name => "Gestione corsi di laurea"
    Capability.create :name => "Gestione privilegi"
     ids = []
    ids << (Capability.find_by_name "Manage timetables").id
    ids << (Capability.find_by_name "Manage buildings").id
    ids << (Capability.find_by_name "Manage classrooms").id
    ids << (Capability.find_by_name "Manage teachings").id
    ids << (Capability.find_by_name "Manage teachers").id
    ids << (Capability.find_by_name "Manage graduate courses").id
    ids << (Capability.find_by_name "Manage capabilities").id
    Capability.destroy(ids)
  end

  def self.down
    ids = []
    ids << (Capability.find_by_name "Gestione docenti").id
    ids << (Capability.find_by_name "Gestione insegnamenti").id
    ids << (Capability.find_by_name "Gestione aule").id
    ids << (Capability.find_by_name "Gestione edifici").id
    ids << (Capability.find_by_name "Gestione schemi d'orario").id
    ids << (Capability.find_by_name "Gestione corsi di laurea").id
    ids << (Capability.find_by_name "Gestione privilegi").id
    Capability.destroy(ids)
  end
end
