require 'test_helper'

class BuildingsControllerTest < ActionController::TestCase

  def setup
    @user = stub_everything(:id => :an_id, :mail => :a_mail, :password => :a_password)
    @user.stubs(:active?).returns(true)
    User.stubs(:find).returns(@user)
    @user.stubs(:manage_buildings?).returns(true)
  end

  test "Guest usa Index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:buildings)
  end

  test "Guest usa Administration" do  #Redirect alla pagina di login
    get :administration
    assert_redirected_to new_session_url
    assert_equal "Effettuare il login" , flash[:notice]
  end

  test "Guest usa New" do  #Redirect alla pagina di login
     get :new
    assert_redirected_to new_session_url
    assert_equal "Effettuare il login" , flash[:notice]
  end

  test "Guest usa Edit" do  #Redirect alla pagina di login
     get :edit ,:id=>:a_id
    assert_redirected_to new_session_url
    assert_equal "Effettuare il login" , flash[:notice]
  end


  test "Guest usa show" do
    building=stub(:name=>:a_name ,:id=>:an_id,:address_id=>:another_id)
    address=stub(:id=>:another_id, :city=>:a_city, :street=>:a_street,:telephone=>:a_telephone)
    Building.stubs(:find).with(:an_id).returns(building)
    Address.stubs(:find).with(:another_id).returns(address)
    get :show, :id  => :an_id
    assert_template 'buildings/show'
    assert_response :success
  end

  test "User con privilegi usa administration" do
    @request.session[:user_id] = :an_id
    get :administration
   assert_template 'buildings/administration'
   assert_response :success

  end

   test "User con privilegi usa new" do
     @request.session[:user_id] = :an_id
     get :new
     assert_response :success
   end

  test "User con privilegi usa edit" do
     @request.session[:user_id] = :an_id
      building = Building.new(:id=>:a_id,:name=>:a_name )
      address = Address.new(:id=>:another_id,:city=>"città", :street=>"street",:telephone=>"telephone")
     Building.stubs(:find).with(:a_id).returns(building)
     Address.stubs(:find).returns(address)
     get :edit, :id=>:a_id
     assert_response :success
  end

  test "User con privilegi crea un palazzo valido" do
    @request.session[:user_id] = :an_id
    Building.any_instance.stubs(:save).returns(true)
    Address.any_instance.stubs(:save).returns(true)
    put :create, :building=>{:name=>:a_name}, :address=>{:city=>"città", :street=>"street",:telephone=>"telephone"}
    assert_redirected_to :action => 'administration'
    assert_equal flash[:notice] ,"Inserimento del nuovo edificio avvenuto con successo"
  end

  test "User con privilegi crea un palazzo con indirizzo non valido" do
    @request.session[:user_id] = :an_id
    Building.any_instance.stubs(:save).returns(true)
    put :create, :building=>{:name=>:a_name ,:address_id=>:another_id}, :address=>{:city=>"città", :street=>"street",:telephone=>"telephone"}
    assert_template 'new'
  end

    test "User con privilegi crea un palazzo non valido" do
       @request.session[:user_id] = :an_id
       address = Address.new()
       address.stubs(:id=>:another_id,:city=>"città", :street=>"street",:telephone=>"telephone")
       Building.any_instance.stubs(:address_id).returns(:another_id)
       Address.any_instance.stubs(:save).returns(true)
       Address.stubs(:find).with(:another_id).returns(address)
       post :create,  :address=> {:city=>"città", :street=>"street",:telephone=>"telephone"}
       assert_template 'new'
     end

     test "User con privilegi modifica un palazzo correttamente" do
       @request.session[:user_id] = :an_id
       building = Building.new(:id=>:a_id,:name=>:a_name )
       address = Address.new(:id=>:another_id,:city=>"città", :street=>"street",:telephone=>"telephone")
       Building.stubs(:find).with(:a_id).returns(building)
       Address.stubs(:find).returns(address)
       building.stubs(:update_attributes).returns(true)
       address.stubs(:update_attributes).returns(true)
      put  :update, :id=>:a_id
      assert_equal flash[:notice] ,"Modifica dell'edificio completata correttamente"
      assert_redirected_to :action=>'administration'
     end

     test "User con privilegi modifica un palazzo in modo non corretto" do
        @request.session[:user_id] = :an_id
       building = Building.new(:id=>:a_id,:name=>:a_name )
       address = Address.new(:id=>:another_id,:city=>"città", :street=>"street",:telephone=>"telephone")
       Building.stubs(:find).with(:a_id).returns(building)
       Address.stubs(:find).returns(address)
       building.stubs(:update_attributes).returns(false)
       address.stubs(:update_attributes).returns(false)
      put  :update, :id=>:a_id
      assert_template 'edit'
     end

     test "User con privilegi elimina un palazzo in modo corretto" do
        @request.session[:user_id] = :an_id
       building = Building.new(:id=>:a_id,:name=>:a_name )
       Building.stubs(:find).with(:a_id).returns(building)
       delete :destroy, :id=>:a_id
       assert_redirected_to :action=>'administration'
     end

end