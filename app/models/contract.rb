class Contract < ActiveRecord::Base
  include AddOrNil
  
  belongs_to :project
  belongs_to :active_bid, :class_name => "Bid", :foreign_key => :bid_id
  
  has_many :tasks, :order => :name
  has_many :costs, :class_name => "ContractCost", :order => "date DESC", :dependent => :destroy
  has_many :bids, :order => :contractor, :dependent => :destroy
  has_many :markups, :as => :parent, :order => :name, :dependent => :destroy
  
  validates_presence_of :name, :project
  
  def cost
    self.costs.inject(nil) {|memo,obj| add_or_nil(memo, obj.cost)}
  end
  
  def bid
    return nil if self.active_bid.blank?
    self.active_bid.cost
  end
end
