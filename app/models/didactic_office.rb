class DidacticOffice < ActiveRecord::Base
  has_one :user, :as => :specified

end