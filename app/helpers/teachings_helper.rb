module TeachingsHelper
  def menu_admin()
    render :partial => "menu_admin"
  end

  def show_teaching_admin(teaching)
    render :partial => "/teachings/teaching_admin", :object => teaching
  end

  def show_teaching(teaching)
    render :partial => "/teachings/teaching", :object => teaching
  end
end
