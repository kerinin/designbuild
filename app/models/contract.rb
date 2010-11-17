class Contract < ActiveRecord::Base
  include AddOrNil
  
  belongs_to :project
  
  has_many :tasks, :order => :name
  has_many :costs, :class_name => "ContractCost", :order => "date DESC"
  has_many :bids, :order => :contractor
  
  validates_presence_of :name, :project
  
  def cost
    self.costs.inject(nil) {|memo,obj| add_or_nil(memo, obj.cost)}
  end
end
