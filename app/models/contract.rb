class Contract < ActiveRecord::Base
  include AddOrNil
  
  belongs_to :project
  belongs_to :active_bid, :class_name => "Bid", :foreign_key => :bid_id
  
  has_many :tasks, :order => :name
  has_many :costs, :class_name => "ContractCost", :order => "date DESC", :dependent => :destroy
  has_many :bids, :order => :contractor, :dependent => :destroy
  has_many :markups, :as => :parent, :order => :name, :dependent => :destroy
  
  validates_presence_of :name, :project

  after_save :add_default_markups
  
  def estimated_cost
    multiply_or_nil 1 + ( self.total_markup / 100 ), self.bid
  end
  
  def cost
    multiply_or_nil 1 + ( self.total_markup / 100 ), self.costs.inject(nil) {|memo,obj| add_or_nil(memo, obj.cost)}
  end
  
  def bid
    return nil if self.active_bid.blank?
    self.active_bid.cost
  end
  
  def total_markup
    self.markups.inject(0) {|memo,obj| memo + obj.percent }
  end
  
  private
  
  def add_default_markups
    self.project.markups.each {|markup| new_markup = markup.clone; new_markup.parent = self; new_markup.save!}
  end
end
