module CurriculumsHelper
  def show_teachings(teachings)
    render :partial => "teachings", :object => teachings
  end
end
