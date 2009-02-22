class BooleanConstraint < ActiveRecord::Base
  #validazioni boolean
  validates_presence_of :boolean,
                          :message=>"Il campo boolean non può essere vuoto"


end
