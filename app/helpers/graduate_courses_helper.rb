module GraduateCoursesHelper
  def menu_admin
    render :partial => "menu_admin"
  end

  def show_graduate_course_admin(graduate_course)
    render :partial => "/graduate_courses/graduate_course_admin", :object => graduate_course
  end

  def show_graduate_course(graduate_course)
    render :partial => "graduate_courses/graduate_course", :object => graduate_course
  end
end
