class Location < ApplicationRecord

  has_many :openingtimes
  validates_with LocationValidator

end


