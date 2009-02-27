module ClassroomsHelper
  def menu_admin
    render :partial => "menu_admin"
  end
  def show_classroom_admin(classroom)
    render :partial => "classroom_admin", :object => classroom
  end

end

