module CurriculumsHelper
  def show_curriculum_admin(curriculum)
    render :partial => "curriculums/curriculum_admin", :object => curriculum
  end
  def show_curriculum(curriculum)
    render :partial => "curriculums/curriculum", :object => curriculum
  end
end
