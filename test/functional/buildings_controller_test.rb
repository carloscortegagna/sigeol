require 'test_helper'

class BuildingsControllerTest < ActionController::TestCase
  include BuildingsHelper
  def setup
    @user = stub_everything(:id => :an_id, :mail => :a_mail, :password => :a_password)
    @user.stubs(:active?).returns(true)
    User.stubs(:find).returns(@user)
    @user.stubs(:manage_buildings?).returns(true)
  end

  #ID = 1
  test "Guest usa Index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:buildings)
  end

  #ID = 2
  test "Guest usa Administration" do  #Redirect alla pagina di login
    get :administration
    assert_redirected_to new_session_url
    assert_equal "Effettuare il login" , flash[:notice]
  end

  #ID = 3
  test "Guest usa New" do  #Redirect alla pagina di login
     get :new
    assert_redirected_to new_session_url
    assert_equal "Effettuare il login" , flash[:notice]
  end

  #ID = 4
  test "Guest usa Edit" do  #Redirect alla pagina di login
     get :edit ,:id=>:a_id
    assert_redirected_to new_session_url
    assert_equal "Effettuare il login" , flash[:notice]
  end

  #ID = 5
  test "Guest usa show" do
    building=stub(:name=>:a_name ,:id=>:an_id,:address_id=>:another_id)
    address=stub(:id=>:another_id, :city=>:a_city, :street=>:a_street,:telephone=>:a_telephone)
    Building.stubs(:find).with(:an_id).returns(building)
    Address.stubs(:find).with(:another_id).returns(address)
    get :show, :id  => :an_id
    assert_template 'buildings/show'
    assert_response :success
  end

  #ID = 6
  test "User con privilegi usa administration" do
    @request.session[:user_id] = :an_id
    get :administration
    show_building(Building.new)
    menu_admin
    show_building_admin(Building.new)
    assert_template 'buildings/administration'
    assert_response :success
  end

  #ID = 7
  test "User con privilegi usa new" do
     @request.session[:user_id] = :an_id
     get :new
     assert_response :success
  end

  #ID = 8
  test "User con privilegi usa edit" do
     @request.session[:user_id] = :an_id
      building = Building.new(:id=>:a_id,:name=>:a_name )
      address = Address.new(:id=>:another_id,:city=>"città", :street=>"street",:telephone=>"049-9075393")
     Building.stubs(:find).with(:a_id).returns(building)
     Address.stubs(:find).returns(address)
     get :edit, :id=>:a_id
     assert_response :success
  end

  #ID = 9
  test "User con privilegi crea un palazzo valido" do
    @request.session[:user_id] = :an_id
    Building.any_instance.stubs(:save).returns(true)
    Address.any_instance.stubs(:save).returns(true)
    post :create, :building=>{:name=>:a_name}, :address=>{:city=>"città", :street=>"street",:telephone=>"telephone"},:prefisso=>"049",:telefono=>"9075656"
    assert_redirected_to :action => 'administration'
    assert_equal flash[:notice] ,"Inserimento del nuovo edificio avvenuto con successo"
  end

  #ID = 10
  test "User con privilegi crea un palazzo con indirizzo non valido" do
    @request.session[:user_id] = :an_id
    Building.any_instance.stubs(:save).returns(true)
    post :create, :building=>{:name=>:a_name ,:address_id=>:another_id}, :address=>{:city=>"", :street=>"street",:telephone=>"telephone"},:prefisso=>"049",:telefono=>"9075333"
    assert_template 'new'
  end

  #ID = 11
  test "User con privilegi crea un palazzo non valido" do
    @request.session[:user_id] = :an_id
    address = Address.new()
    address.stubs(:id=>:another_id,:city=>"città", :street=>"street",:telephone=>"telephone")
    Building.any_instance.stubs(:address_id).returns(:another_id)
    Address.any_instance.stubs(:save).returns(true)
    Address.stubs(:find).with(:another_id).returns(address)
    post :create,  :address=> {:city=>"città", :street=>"street",:telephone=>"telephone"},:prefisso=>"049",:telefono=>"9075333"
    assert_template 'new'
  end

  #ID = 12
  test "User con privilegi modifica un palazzo correttamente" do
    @request.session[:user_id] = :an_id
    building = Building.new(:id=>:a_id,:name=>:a_name )
    address = Address.new(:id=>:another_id,:city=>"città", :street=>"street",:telephone=>"telephone")
    Building.stubs(:find).with(:a_id).returns(building)
    Address.stubs(:find).returns(address)
    building.stubs(:update_attributes).returns(true)
    address.stubs(:update_attributes).returns(true)
    put  :update, :id=>:a_id,:prefisso=>"049",:telefono=>"9075333"
    assert_equal flash[:notice] ,"Modifica dell'edificio completata correttamente"
    assert_redirected_to :action=>'administration'
  end

  #ID = 13
  test "User con privilegi modifica un palazzo in modo non corretto" do
    @request.session[:user_id] = :an_id
    building = Building.new(:id=>:a_id,:name=>:a_name )
    address = Address.new(:id=>:another_id,:city=>"città", :street=>"street",:telephone=>"telephone")
    Building.stubs(:find).with(:a_id).returns(building)
    Address.stubs(:find).returns(address)
    building.stubs(:update_attributes).returns(false)
    address.stubs(:update_attributes).returns(false)
    put  :update, :id=>:a_id,:prefisso=>"049",:telefono=>"9075333"

    assert_template 'edit'
  end

  #ID = 14
  test "User con privilegi elimina un palazzo in modo corretto" do
    @request.session[:user_id] = :an_id
    address = Address.new(:id=>:another_id,:city=>"città", :street=>"street",:telephone=>"telephone")
    building = Building.new(:id=>:a_id,:name=>:a_name )
    Building.stubs(:find).with(:a_id).returns(building)
    Address.stubs(:find).returns(address)
    delete :destroy, :id=>:a_id
    assert_redirected_to :action=>'administration'
  end

  #ID = 15
  test"User senza privilegi usa administration"do
    @request.session[:user_id] = :an_id
    @user.stubs(:manage_buildings?).returns(false)
    get :administration
    assert_equal flash[:error],"Non possiedi i privilegi per effettuare questa operazione"
    assert_redirected_to timetables_url
  end
   
  #ID = 16
  test"User senza privilegi usa new"do
    @request.session[:user_id] = :an_id
    @user.stubs(:manage_buildings?).returns(false)
    get :new
    assert_equal flash[:error],"Non possiedi i privilegi per effettuare questa operazione"
    assert_redirected_to timetables_url
  end

  #ID = 17
  test"User senza privilegi usa edit"do
    @request.session[:user_id] = :an_id
    @user.stubs(:manage_buildings?).returns(false)
    get :edit,:id=>:an_id
    assert_equal flash[:error],"Non possiedi i privilegi per effettuare questa operazione"
    assert_redirected_to timetables_url
  end

  #ID = 18
  test"User senza privilegi usa create"do
    @request.session[:user_id] = :an_id
    @user.stubs(:manage_buildings?).returns(false)
    post :create,:id=>:an_id
    assert_equal flash[:error],"Non possiedi i privilegi per effettuare questa operazione"
    assert_redirected_to timetables_url
  end

  #ID = 19
  test"User senza privilegi usa update"do
    @request.session[:user_id] = :an_id
    @user.stubs(:manage_buildings?).returns(false)
    menu_admin
    put :update,:id=>:an_id
    assert_equal flash[:error],"Non possiedi i privilegi per effettuare questa operazione"
    assert_redirected_to timetables_url
  end

  #ID = 20
  test"User senza privilegi usa destroy"do
    @request.session[:user_id] = :an_id
    @user.stubs(:manage_buildings?).returns(false)
    delete :destroy,:id=>:an_id
    assert_equal flash[:error],"Non possiedi i privilegi per effettuare questa operazione"
    assert_redirected_to timetables_url
  end

  private
    def render(a)
       a = "Sigeol"
    end
end