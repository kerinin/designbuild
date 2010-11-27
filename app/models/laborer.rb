class Laborer < ActiveRecord::Base
  has_paper_trail
  
  belongs_to :project
  
  has_many :labor_cost_lines, :dependent => :destroy
  
  validates_presence_of :project, :bill_rate
  
  validates_numericality_of :bill_rate
  
  after_save :cache_values
  after_destroy :cache_values
  
  private
  
  def cache_values
    self.labor_cost_lines.all.each {|lc| lc.cache_values}
  end
end
