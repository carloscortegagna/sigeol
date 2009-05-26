# QuiXoft - Progetto ”SIGEOL”
# NOME FILE: constraints_owner.rb
# AUTORE: Grosselle Alessandro
# DATA CREAZIONE: 12/02/2009
# 
# REGISTRO DELLE MODIFICHE:
#
# 26/03/2009 Approvazione del responsabile
#
# 10/03/2009 Aggiunta delle associazioni
#
# 12/02/2009 Prima stesura


#Rappresenta l'associazione tra corsi di laurea (_Graduate_course_), tipologia di
#vincoli (_Quantity_constraint_, _Temporal_constraint_,_Boolean_constraint_) e
#possessori di vincoli (_Teacher_,_Classroom_,_Graduate_course_).

class ConstraintsOwner < ActiveRecord::Base
 belongs_to :graduate_course
 belongs_to :constraint, :polymorphic=>true
 belongs_to :owner, :polymorphic=>true
 acts_as_double_polymorphic_join(
  :owners =>[:teachers, :classrooms, :graduate_courses],
  :constraints => [:quantity_constraints,:temporal_constraints,:boolean_constraints]
) 
end
