require 'test_helper'
require 'digest/sha1'

class UserTest < ActiveSupport::TestCase
  def setup
    d=DidacticOffice.new
    d.id=1
    d.save
    @u=users(:user_1)
    @u.capabilities<<Capability.find(:all)
    @u.specified=d
    @u.save
  end
  
  def test_attribute_not_nil
    u=User.new
    assert !u.errors.invalid?(:mail)
  end

  def test_validate_password
    @u.password=""
    assert !@u.save
    assert_equal "La password non deve essere vuota", @u.errors.on(:password).first

    @u.password="prova"
    assert !@u.save
    assert_equal "La password troppo corta. Min 6 caratteri", @u.errors.on(:password)

    @u.password="pro.va"
    assert @u.save
  end

  def test_validate_mail
    @u.mail="prova?id=1@math.unipd.it"
    assert !@u.save
    assert_equal "La mail non è valida", @u.errors.on(:mail)

    @u.mail="agrossel@math.unipd.it"
    assert @u.save
  end

  def test_unique_mail
    u=User.new(:mail=>users(:user_2).mail,:random=>2)
    assert !u.save
    assert_equal "La mail è già presente", u.errors.on(:mail)
  end

 def test_encrypt_password
   password=User.find(users(:user_1).id).password
   p=Digest::SHA1.hexdigest("alessandro")
   assert_equal password, p
 end

def test_user_must_be_specified
  d=DidacticOffice.new
  d.save
  u=users(:user_2)
  assert !u.save
  u.specified=d
  assert u.save
end

def test_authenticate
  u=User.authenticate("prova@math.unipd.it", "password")
  assert !u
  u=User.authenticate("agrossel@math.unipd.it", "alessandro")
  assert u.active?
end

def test_destroy_user
  assert @u.destroy
  assert_raise(ActiveRecord::RecordNotFound) { DidacticOffice.find( @u.specified_id ) }
  assert_raise(ActiveRecord::RecordNotFound) { Address.find(@u.address_id) }
  end

def test_presence_of_capabilities
  assert @u.manage_buildings?
  assert @u.manage_capabilities?
  assert @u.manage_classrooms?
  assert @u.manage_graduate_courses?
  assert @u.manage_teachers?
  assert @u.manage_timetables?
  assert @u.manage_teachings?
end

def test_check_if_user_is_didactic_office
  assert @u.own_by_didactic_office?
  assert !@u.own_by_teacher?
end

def test_try_to_destroy_user_associated_to_graduate_course
  @u.graduate_courses<<graduate_courses(:graduate_course_1)
  @u.save
  assert_raise(Exception){@u.destroy}
end
end
