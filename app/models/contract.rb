class Contract < ActiveRecord::Base
  include AddOrNil
  
  has_paper_trail
  
  belongs_to :project
  belongs_to :active_bid, :class_name => "Bid", :foreign_key => :bid_id
  
  has_many :tasks, :order => :name
  has_many :costs, :class_name => "ContractCost", :order => "date DESC", :dependent => :destroy
  has_many :bids, :order => :contractor, :dependent => :destroy

  has_many :markings, :as => :markupable, :dependent => :destroy
  has_many :markups, :through => :markings, :after_add => :cache_values, :after_remove => :cache_values
  
  validates_presence_of :name, :project

  after_create :add_project_markups
  after_save :cache_values  
  after_destroy :cache_values
  
  def cost
    multiply_or_nil self.raw_cost, (1+(self.total_markup/100))
  end
  
  # raw_cost
  
  def invoiced
    multiply_or_nil self.raw_invoiced, (1+(self.total_markup/100))
  end
  
  # raw_invoiced
  
  
  private
  
  def cache_values
    self.cache_raw_cost
    self.cache_raw_invoiced
    self.cache_total_markup
    
    self.project.cache_values
  end
  
  def cache_raw_cost
    self.raw_cost = self.active_bid.blank? ? nil : self.active_bid.raw_cost
  end
  
  def cache_raw_invoiced
    self.raw_invoiced = self.costs.inject(nil) {|memo,obj| add_or_nil(memo, obj.raw_cost)}
  end
  
  def cache_total_markup
    self.total_markup = self.markups.inject(0) {|memo,obj| memo + obj.percent }
  end
  
  
  def add_project_markups
    self.project.markups.each {|m| self.markups << m unless self.markups.include? m }
  end
end
