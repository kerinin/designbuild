class Contract < ActiveRecord::Base
  include AddOrNil
  
  belongs_to :project
  
  has_many :tasks
  has_many :costs, :class_name => "ContractCost"
  has_many :bids
  
  validates_presence_of :project
  
  def cost
    self.costs.inject(nil) {|memo,obj| add_or_nil(memo, obj.cost)}
  end
end
