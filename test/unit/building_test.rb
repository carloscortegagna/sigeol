require 'test_helper'

class BuildingTest < ActiveSupport::TestCase
 def setup
   @b=Building.new
 end

 def test_attribute_not_nil
    assert !@b.valid
    assert @b.error.invalid?(:name)
    assert @b.error.invalid?(:address_id)
 end
 
 def test_unique_name
    @b.name=Bulding(:buildings_1).name
    @b.address=Bulding(:buildings_1).address
    assert !@b.save
    assert_equal "Esiste già un palazzo con questo nome", @b.errors.on(:name)
 end

 def test_destroy_building
   b=Building(:buildings_1)
   assert @b.destroy
   assert !Classroom.find(:all)
 end
end
