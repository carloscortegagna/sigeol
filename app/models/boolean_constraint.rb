class BooleanConstraint < ActiveRecord::Base
  #validazioni boolean
  validates_inclusion_of :bool,
                         :in => [true, false],
                         :allow_nil=>false,
                         :message=>"Inserisci un valore per bool valido"
end
