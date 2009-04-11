#QuiXoft - Progetto ”SIGEOL”
#NOME FILE: didactic_office_test.rb
#AUTORE: Grosselle Alessandro

require 'test_helper'

class DidacticOfficeTest < ActiveSupport::TestCase
 #test25: eliminazione di un utente di tipo segreteria didattica
  def test_destroy_didactic_office
    #caso di prova 25.1: eliminazione dell'oggetto d di tipo DidacticOffice
    #obiettivo: u è un oggetto di tipo User associato a d. Eliminando d, anche lo user associato
     #deve essere cancellato
    u=users(:user_1)
    d=DidacticOffice.new
    d.save
    u.specified=d
    u.save
    assert d.destroy
    assert_raise(ActiveRecord::RecordNotFound) { User.find( u.id ) }
  end
end