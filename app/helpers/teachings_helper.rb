module TeachingsHelper
  def show_teaching(teaching)
    render :partial => "teaching", :object => teaching
  end
  def show_teacher(teacher)
    if teacher
      render :partial => "teacher", :object => teacher
    end
  end
end
