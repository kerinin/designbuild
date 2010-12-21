class Invoice < ActiveRecord::Base
  belongs_to :project, :inverse_of => :invoices
  
  has_many :lines, :class_name => 'InvoiceLine'
  
  accepts_nested_attributes_for :lines
  
  validates_presence_of :project
  
  before_update Proc.new{|i| i.advance; true}
  
  state_machine :state, :initial => :new do
    # States
    state :new do
    end
    
    state :missing_task do
    end
    
    state :payments_unbalanced do
    end
    
    state :retainage_expected do
    end
    
    state :retainage_unexpected do
      # retainage isn't the expected % of invoiced
    end
    
    state :costs_specified do
    end
        
    state :complete do
    end
    
    before_transition [:new, :missing_task, :payments_unbalanced] => :retainage_expected, :do => :populate_lines
    
    # Events
    event :advance do
      transition :new => :missing_task, :if => Proc.new{|inv| inv.date? && inv.missing_tasks? }
      transition :new => :payments_unbalanced, :if => Proc.new{|inv| inv.date? && inv.unbalanced_payments? }, :unless => :missing_tasks?
      
      transition :missing_task => :payments_unbalanced, :if => :unbalanced_payments?, :unless => :missing_tasks?
      #transition :missing_task => :retainage_expected, :if => Proc.new{|inv| inv.date? && !inv.missing_tasks? && !inv.unbalanced_payments? }
      
      transition [:new, :missing_task, :payments_unbalanced] => :retainage_expected, :if => Proc.new{|inv| inv.date? && !inv.missing_tasks? && !inv.unbalanced_payments? }
      
      transition :retainage_unexpected => :retainage_expected, :if => :retainage_as_expected?
      transition :retainage_expected => :retainage_unexpected, :unless => :retainage_as_expected?    
      
      transition :costs_specified => :complete, :if => :template?
    end
    
    event :accept_costs do
      transition any - :new => :costs_specified
    end
  end
  
  [:labor_invoiced, :material_invoiced, :invoiced, :labor_retainage, :material_retainage, :retainage].each do |sym|
    self.send(:define_method, sym) do
      self.lines.inject(0) {|memo,obj| memo + obj.send(sym)}
    end
  end
  
  def retainage_as_expected?
    self.lines(true).each {|l| return false unless l.retainage_as_expected? }
    true
  end
  
  def missing_tasks?
    self.project(true).tasks.where('raw_labor_cost > 0 OR raw_material_cost > 0').map{ |task| 
      task.unit_cost_estimates.empty? && task.fixed_cost_estimates.empty?
    }.include?( true ) 
  end
  
  def unbalanced_payments?
    # Reload required!
    return false if self.project(true).payments.empty?
    self.project(true).payments.map{|p| p.balances?}.include?( false )
  end
  
  protected
  
  def populate_lines
    self.project(true).components.each do |component|
      component.unit_cost_estimates.assigned.each {|uc| line = self.lines.build(:cost => uc); line.set_defaults; line.save! }
      component.fixed_cost_estimates.assigned.each {|fc| line = self.lines.build(:cost => fc); line.set_defaults; line.save! }
      component.contracts.each {|c| line = self.lines.build(:cost => c); line.set_defaults; line.save! }
    end
    
    self.project.contracts.scoped.without_component.each {|c| line = self.lines.build(:cost => c); line.set_defaults; line.save! }
  end
end
