class Supplier < ActiveRecord::Base
  has_many :material_costs
end
