module TeachersHelper
  def menu_admin
    render :partial => "menu_admin"
  end
  def show_not_active_users(users)
    unless users.empty?
      render :partial => "not_active_users", :object => users
    end
  end
  def show_graduate_course_admin(graduate_course)
    render :partial => "graduate_course_admin", :object => graduate_course
  end

  def show_teacher_admin(teacher)
    render :partial => "teacher_admin", :object => teacher
  end
end
