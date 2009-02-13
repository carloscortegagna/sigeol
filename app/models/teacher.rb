class Teacher < ActiveRecord::Base
    has_one :user, :as => :specified
    #si associa teacher ai vincol temporali(temporal constraint)
    has_many_polymorphs :constraints, :from=>[:temporal_constraints],
      :as=> :owner
  validates_associated :user
end
