class BooleanConstraint < ActiveRecord::Base
  #validazioni boolean
  validates_presence_of :bool,
                          :message=>"Il campo boolean non può essere vuoto"


end
