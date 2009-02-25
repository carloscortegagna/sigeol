module TeachingsHelper
  def menu_admin()
    render :partial => "menu_admin"
  end

  def show_teachings_for_graduate_course_admin(graduate_course)
    teachings = Teaching.find(:all, :select => "DISTINCT teachings.id",
                              :include => {:curriculums => :graduate_course},
                              :conditions => ["graduate_courses.id = ?",graduate_course.id])
    unless teachings.empty?
      render :partial => "teachings_admin", :object => teachings
    else
      render :text => "Nessun insegnamento presente"
    end
  end

  def show_teaching(teaching)
    render :partial => "teaching", :object => teaching
  end

  def show_teacher(teacher)
    if teacher
      render :partial => "teacher", :object => teacher
    end
  end
end
