class Contract < ActiveRecord::Base
  include AddOrNil
  include MarksUp
  
  has_paper_trail
  
  belongs_to :project
  belongs_to :active_bid, :class_name => "Bid", :foreign_key => :bid_id
  
  has_many :tasks, :order => :name
  has_many :costs, :class_name => "ContractCost", :order => "date DESC", :dependent => :destroy
  has_many :bids, :order => :contractor, :dependent => :destroy

  has_many :markings, :as => :markupable, :dependent => :destroy
  has_many :markups, :through => :markings
  
  validates_presence_of :name, :project

  after_create :add_project_markups
  
  before_save :cache_values
  
  after_save :cascade_cache_values  
  after_destroy :cascade_cache_values
  
  marks_up :raw_cost
  #def cost
  #  multiply_or_nil self.raw_cost, (1+(self.total_markup/100))
  #end
  
  # raw_cost
  
  marks_up :raw_invoiced
  #def invoiced
  #  multiply_or_nil self.raw_invoiced, (1+(self.total_markup/100))
  #end
  
  # raw_invoiced
  
  def cache_values
    [self.bids, self.costs, self.markups].each {|r| r.reload}
    
    self.cache_raw_cost
    self.cache_raw_invoiced
    self.cache_total_markup
  end
    
  def cascade_cache_values
    self.project.save!
  end
  
  
  protected  
  
  def cache_raw_cost
    self.raw_cost = ( (self.active_bid.blank? || self.active_bid.destroyed?) ? nil : self.active_bid.raw_cost )
  end
  
  def cache_raw_invoiced
    self.raw_invoiced = self.costs.all.inject(nil) {|memo,obj| add_or_nil(memo, obj.raw_cost)}
  end
  
  def cache_total_markup
    self.total_markup = self.markups.all.inject(0) {|memo,obj| memo + obj.percent }
  end
  
  
  def add_project_markups
    self.project.markups.all.each {|m| self.markups << m unless self.markups.include? m }
  end
end
