module ClassroomsHelper
  def menu_admin
    render :partial => "/classrooms/menu_admin"
  end
  def show_classroom_admin(classroom)
    render :partial => "/classrooms/classroom_admin", :object => classroom
  end
  def show_classroom(classroom)
    render :partial => "/classrooms/classroom", :object => classroom
  end

end

