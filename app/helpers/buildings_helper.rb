module BuildingsHelper
  def menu_admin
    render :partial => "/buildings/menu_admin"
  end
  def show_building_admin(building)
    render :partial => "/buildings/building_admin", :object => building
  end
  def show_building(building)
    render :partial => "buildings/building", :object => building
  end
end
