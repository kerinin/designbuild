class Payment < ActiveRecord::Base
  belongs_to :project
  
  has_many :lines, :class_name => 'PaymentLine'
  
  accepts_nested_attributes_for :lines
  
  validates_presence_of :project
  validates_numericality_of :paid, :if => :paid?
  validates_numericality_of :retained, :if => :retained?
  
  before_update Proc.new{|i| i.advance; true}
  before_save :update_invoices
  
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
    
    before_transition [:new, :missing_task] => [:balanced, :unbalanced], :do => :populate_lines
    after_transition [:new, :missing_task] => [:balanced, :unbalanced], :do => Proc.new{|p| p.lines.each {|l| l.save!} }
    
    # Events
    event :advance do
      transition :new => :missing_task, :if => Proc.new{|p| !p.date.nil? && !p.paid.nil? && !p.retained.nil? && p.missing_tasks? }
      
      transition :missing_task => :balanced, :if => Proc.new{|p| !p.date.nil? && !p.paid.nil? && !p.retained.nil? && !p.missing_tasks? }
      
      transition :new => :balanced, :if => Proc.new{|p| !p.date.nil? && !p.paid.nil? && !p.retained.nil? && !p.missing_tasks? && p.balances? }
      transition :new => :unbalanced, :if => Proc.new{|p| !p.date.nil? && !p.paid.nil? && !p.retained.nil? && !p.missing_tasks? && !p.balances?}
      
      transition :unbalanced => :balanced, :if => :balances?
      transition :balanced => :unbalanced, :unless => :balances?    
    end
    
    event :accept_payment do
      transition :balanced => :complete
    end
  end
  
  [:labor_paid, :material_paid, :labor_retained, :material_retained].each do |sym|
    self.send(:define_method, sym) do
      self.lines.inject(0) {|memo,obj| memo + obj.send(sym)}
    end
  end
  
  def missing_tasks?
    self.project.tasks.where('raw_labor_cost > 0 OR raw_material_cost > 0').map{ |task| 
      task.unit_cost_estimates.empty? && task.fixed_cost_estimates.empty?
    }.include?( true ) 
  end
  
  def balances?
    return false if self.paid.nil? || self.retained.nil?
    
    paid_sum = self.labor_paid + self.material_paid
    ret_sum = self.labor_retained + self.material_retained
    
    paid_sum.round_to(2) == self.paid.round_to(2) && ret_sum.round_to(2) == self.retained.round_to(2)
  end
  
  #protected
  
  def populate_lines
    self.project.components.each do |component|
      component.unit_cost_estimates.assigned.each {|uc| line = self.lines.build(:cost => uc); line.set_defaults }
      component.fixed_cost_estimates.assigned.each {|fc| line = self.lines.build(:cost => fc); line.set_defaults }
      component.contracts.each {|c| line = self.lines.build(:cost => c); line.set_defaults }
    end
    
    self.project.contracts.scoped.without_component.each {|c| line = self.lines.build(:cost => c); line.set_defaults }
    true
  end
  
  def update_invoices
    # Reload (probably) required
    self.project.reload.invoices.each {|i| i.save!}
    true
  end
end
