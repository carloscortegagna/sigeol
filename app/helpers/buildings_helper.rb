module BuildingsHelper
  def menu_admin
    render :partial => "menu_admin"
  end
  def show_building_admin(building)
    render :partial => "building_admin", :object => building
  end
end
