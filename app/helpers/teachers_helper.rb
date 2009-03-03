module TeachersHelper
  def menu_admin
    render :partial => "menu_admin"
  end

  def show_teacher_admin(teacher)
    render :partial => "/teachers/teacher_admin", :object => teacher
  end

  def show_teacher(teacher)
    render :partial => "/teachers/teacher", :object => teacher
  end
end
