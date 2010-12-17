class Payment < ActiveRecord::Base
  belongs_to :project
  
  has_many :lines, :class_name => 'PaymentLine'
  
  accepts_nested_attributes_for :lines
  
  validates_presence_of :project
  
  before_update Proc.new{|i| i.advance; true}
  
  state_machine :state, :initial => :new do
    # States
    state :new do
    end
    
    state :missing_task do
    end
    
    state :balanced do
    end
    
    state :unbalanced do
      # line items don't equal paid
    end
        
    state :complete do
    end
    
    before_transition [:new, :missing_task] => :retainage_expected, :do => :populate_lines
    
    # Events
    event :advance do
      transition :new => :missing_task, :if => Proc.new{|p| p.date? && p.paid? && p.retained? && inv.missing_tasks? }
      
      transition :missing_task => :balanced, :if => Proc.new{|p| p.date? && p.paid? && p.retained? && !p.missing_tasks? }
      
      transition :new => :balanced, :if => Proc.new{|p| p.date? && p.paid? && p.retained? && !p.missing_tasks? }
      
      transition :unbalanced => :balanced, :if => :balances?
      transition :balanced => :unbalanced, :unless => :balances?    
    end
    
    event :accept_payment do
      transition :balanced => :complete
    end
  end
  
  def missing_tasks?
    self.project.tasks.where('raw_labor_cost > 0 OR raw_material_cost > 0').map{ |task| 
      task.unit_cost_estimates.empty? && task.fixed_cost_estimates.empty?
    }.include?( true ) 
  end
  
  def balances?
    false
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
