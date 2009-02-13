class Classroom < ActiveRecord::Base
  belongs_to :builiding
  has_many_polymorphs :constraints, :from=>[:boolean_constraints, :temporal_constraints],
    :as=> :owner
end
