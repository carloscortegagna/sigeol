class User < ActiveRecord::Base
   belongs_to :specified, :polymorphic => true
   has_and_belongs_to_many :capabilities
   belongs_to :address
end
