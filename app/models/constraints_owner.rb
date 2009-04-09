#QuiXoft - Progetto ”SIGEOL”
#NOME FILE: classroom.rb
#VERSIONE: 0.3
#AUTORE: Grosselle Alessandro
#DATA CREAZIONE: 19/02/09
#REGISTRO DELLE MODIFICHE:
#10/03/09 Aggiunta delle associazioni
#19/02/09 Prima stesura

class ConstraintsOwner < ActiveRecord::Base
 belongs_to :graduate_course
 belongs_to :constraint, :polymorphic=>true
 belongs_to :owner, :polymorphic=>true
 acts_as_double_polymorphic_join(
  :owners =>[:teachers, :classrooms, :graduate_courses],
  :constraints => [:quantity_constraints,:temporal_constraints,:boolean_constraints]
) 
end
