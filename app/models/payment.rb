class Payment < ActiveRecord::Base
  belongs_to :project, :inverse_of => :payments
  
  has_many :lines, :class_name => 'PaymentLine', :dependent => :destroy, :after_add => :update_invoices, :after_remove => :update_invoices
  has_many :markup_lines, :class_name => 'PaymentMarkupLine', :dependent => :destroy
  
  accepts_nested_attributes_for :lines
  
  validates_presence_of :project
  validates_numericality_of :paid, :if => :paid?
  validates_numericality_of :retained, :if => :retained?
  
  after_save :update_invoices
  
  state_machine :state, :initial => :new do
    # States
    state :new do
    end
    
    state :unassigned_costs do
    end
    
    state :balanced do
    end
    
    state :unbalanced do
      # line items don't equal paid
    end
        
    state :complete do
    end
    
    after_transition [:new, :unassigned_costs] => [:balanced, :unbalanced], :do => :populate_lines
    after_transition any => :balanced, :do => Proc.new{|p| p.project.invoices.each{|pr| pr.advance!}}
    
    # Events
    event :advance do
      transition :new => :unassigned_costs, :if => Proc.new{|p| !p.date.nil? && !p.paid.nil? && !p.retained.nil? && p.unassigned_costs? }
      
      transition :unassigned_costs => :balanced, :if => Proc.new{|p| !p.date.nil? && !p.paid.nil? && !p.retained.nil? && !p.unassigned_costs? && p.balances? }
      transition :unassigned_costs => :unbalanced, :if => Proc.new{|p| !p.date.nil? && !p.paid.nil? && !p.retained.nil? && !p.unassigned_costs? && !p.balances? }
            
      transition :new => :balanced, :if => Proc.new{|p| !p.date.nil? && !p.paid.nil? && !p.retained.nil? && !p.unassigned_costs? && p.balances? }
      transition :new => :unbalanced, :if => Proc.new{|p| !p.date.nil? && !p.paid.nil? && !p.retained.nil? && !p.unassigned_costs? && !p.balances?}
      
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
  
  def advance!
    self.save! if self.advance
  end
  
  def unassigned_costs?
    !self.project.material_costs.where(:component_id => nil).empty? || !self.project.labor_costs.where(:component_id => nil).empty?
    #self.project.tasks.where('raw_labor_cost > 0 OR raw_material_cost > 0').map{ |task| 
    #  task.unit_cost_estimates.empty? && task.fixed_cost_estimates.empty?
    #}.include?( true ) 
  end
  
  def paid_balances?
    return false if self.paid.nil?
    paid_sum = self.labor_paid + self.material_paid
    paid_sum.round_to(2) == self.paid.round_to(2)
  end
  
  def retained_balances?
    return false if self.retained.nil?
    ret_sum = self.labor_retained + self.material_retained
    ret_sum.round_to(2) == self.retained.round_to(2)
  end
  
  def balances?
    self.paid_balances? && self.retained_balances?
  end
  
  #protected
  
  def populate_lines
    self.project.components.each do |component|
      line = self.lines.create!(:component_id => component.id)
      line.set_defaults
      line.save
      
      #[component.unit_cost_estimates.assigned, component.fixed_cost_estimates.assigned, component.contracts].each do |association|
      #  association.all.each do |c|
      #    line = self.lines.build :cost => c
      #    line.set_defaults
      #    line.save
      #  end
      #end
    end
    
    self.project.contracts.scoped.without_component.each {|c| line = PaymentLine(:payment => self, :cost => c); self.lines << line; line.set_defaults }
    true
  end
  
  def update_invoices(*args)
    self.project.invoices.each {|i| i.advance; i.save! }
    true
  end
end
