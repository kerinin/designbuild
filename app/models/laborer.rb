class Laborer < ActiveRecord::Base
  has_paper_trail :ignore => [:created_at, :updated_at]
  
  belongs_to :project
  
  has_many :labor_cost_lines #, :dependent => :destroy
  
  validates_presence_of :bill_rate
  
  validates_numericality_of :bill_rate
  validates_numericality_of :pay_rate, :if => :pay_rate
  
  after_save :cascade_cache_values
  after_destroy :cascade_cache_values

  def cascade_cache_values
    self.labor_cost_lines(true).all.each {|lc| lc.save!}
  end
end
