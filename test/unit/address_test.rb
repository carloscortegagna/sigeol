require 'test_helper'

class AddressTest < ActiveSupport::TestCase
  fixtures :users, :buildings, :addresses
  def setup
    @a=Address.new
  end

  def test_attribute_not_nil
    
    assert !@a.valid?
    assert_equal "Inserisci la città" , @a.errors.on(:city).first
    assert_equal "Inserisci la via" , @a.errors.on(:street).first
  end

  def test_correct_telephone
     @a.telephone="12345-123456"
     assert !@a.valid?
     assert_equal "Inserisci in questo modo: prefisso-numero" , @a.errors.on(:telephone)

    @a.telephone="1234-12345"
     assert !@a.valid?
     assert_equal "Inserisci in questo modo: prefisso-numero" , @a.errors.on(:telephone)

    @a.telephone="1a23-12345"
     assert !@a.valid?
     assert_equal "Inserisci in questo modo: prefisso-numero" , @a.errors.on(:telephone)
     assert !@a.valid?

    @a.telephone="1234-123456"
     assert !@a.valid?
  end

  def test_destroy_user
    u=users(:user_1)
    u.delete
    !assert(Address.find(u.address_id))
  end

  def test_destroy_address_in_user_address_id_must_nil
    addresses(:address_1).delete
    !assert(users(:user_1).address_id)
  end

  def test_destroy_building
    b=buildings(:building_1)
    b.delete
    !assert(Address.find(b.address_id))
  end

  def test_destroy_address_in_building_address_id_must_nil
    addresses(:address_2).delete
    !assert(buildings(:building_1).address_id)
  end
end
