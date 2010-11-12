class Contract < ActiveRecord::Base
  belongs_to :project
  
  has_many :tasks
  has_many :costs, :class_name => "ContractCost"
  has_many :bids
  
  validates_presence_of :project
  
  def cost
    self.costs.empty? ? nil : self.costs.inject(nil) {|memo, obj| cost = obj.cost; memo.nil? ? obj.cost : memo + (cost.nil? ? 0 : cost)}
  end
end
