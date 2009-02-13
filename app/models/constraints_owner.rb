class ConstraintsOwner < ActiveRecord::Base
 belongs_to :constraint, :polymorphic=>true
 belongs_to :owner, :polymorphic=>true
 acts_as_double_polymorphic_join(
  :owners =>[:teachers, :classrooms, :graduate_courses],
  :constraints => [:quantity_constraints,:temporal_constraints,:boolean_constraints]
) 
end
