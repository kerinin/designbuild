class Laborer < ActiveRecord::Base
  validates_presence_of :bill_rate
end
