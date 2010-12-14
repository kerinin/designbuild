class Invoice < ActiveRecord::Base
  belongs_to :project
  
  has_many :lines, :class_name => 'InvoiceLine'
  
  validates_presence_of :project
  
  before_save Proc.new{|i| i.advance; true}
  
  state_machine :state, :initial => :new do
    # States
    state :new do
    end
    
    state :date_set do
    end
    
    state :costs_specified do
    end
    
    state :retainage_expected do
    end
    
    state :retainage_unexpected do
      # retainage isn't the expected % of invoiced
    end
    
    state :complete do
    end
    
    before_transition :new => :date_set, :do => :populate_lines
    
    # Events
    event :advance do
      transition :new => :date_set, :if => :date?
      
      transition [:date_set, :retainage_unexpected] => :retainage_expected, :if => :retainage_as_expected?
      transition [:date_set, :retainage_expected] => :retainage_unexpected, :unless => :retainage_as_expected?    
      
      transition :costs_specified => :complete, :if => :template?
    end
    
    event :accept_costs do
      transition any - :new => :costs_specified
    end
  end
  
  def retainage_as_expected?
    self.lines.each {|l| return false unless l.retainage_as_expected? }
    true
  end
  
  protected
  
  def populate_lines
    self.project.components.each do |component|
      component.unit_cost_estimates.assigned.each {|uc| self.lines.create!(:cost => uc) }
      component.fixed_cost_estimates.assigned.each {|fc| self.lines.create!(:cost => fc) }
      component.contracts.each {|c| self.lines.create!(:cost => c) }
    end
    
    self.project.contracts.scoped.without_component.each {|c| self.lines.create!(:cost => c) }
  end
end
