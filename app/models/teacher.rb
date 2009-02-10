class Teacher < ActiveRecord::Base
    has_one :user, :as => :specified
    has_many :teachings
end
