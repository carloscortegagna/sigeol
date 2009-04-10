#QuiXoft - Progetto ”SIGEOL”
#NOME FILE: belong_test.rb
#AUTORE: Grosselle Alessandro

require 'test_helper'

class BooleanConstraintTest < ActiveSupport::TestCase

 #test10: creare un'associazione tra un curriculum ed un insegnamento che già esiste
  def test_create_association_curriculum_teaching_that_exists_yet
    #caso di prova10.1: si crea un'associazione tra :curriculum_1 e :teaching_1
    #obiettivo: poichè è già esistente, il sistema deve riconoscere che l'associazione non è valida
     c=curriculums(:curriculum_1)
     t=teachings(:teaching_1)
     b=Belong.new(:teaching => t,:curriculum=>c, :isOptional => true)
     assert !b.valid?
     assert_equal "L'insegnamento è gia assegnato al curriculum", b.errors.on(:base)
  end
  end