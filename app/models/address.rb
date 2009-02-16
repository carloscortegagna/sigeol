class Address < ActiveRecord::Base
  has_one :user
  has_one :building
end
