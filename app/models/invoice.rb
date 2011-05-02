class Invoice < ActiveRecord::Base
  belongs_to :project, :inverse_of => :invoices
  
  has_many :lines, :class_name => 'InvoiceLine', :dependent => :destroy
  has_many :markup_lines, :class_name => 'InvoiceMarkupLine', :dependent => :destroy
  
  accepts_nested_attributes_for :lines
  accepts_nested_attributes_for :markup_lines
  
  validates_presence_of :project
  
  state_machine :state, :initial => :new do
    # States
    state :new do
    end
    
    state :unassigned_costs do
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
    
    state :markups_added do
    end
        
    state :complete do
    end
    
    after_transition [:new, :unassigned_costs, :payments_unbalanced] => [:retainage_expected, :retainage_unexpected], :do => :populate_lines
    
    # Events
    event :advance do
      transition :new => :unassigned_costs, :if => Proc.new{|inv| inv.date? && inv.unassigned_costs? }
      transition :new => :payments_unbalanced, :if => Proc.new{|inv| inv.date? && inv.unbalanced_payments? }, :unless => :unassigned_costs?
      
      transition :unassigned_costs => :payments_unbalanced, :if => :unbalanced_payments?, :unless => :unassigned_costs?
      
      transition [:new, :unassigned_costs, :payments_unbalanced] => :retainage_expected, :if => Proc.new{|inv| inv.date? && !inv.unassigned_costs? && !inv.unbalanced_payments? }
      
      transition :retainage_unexpected => :retainage_expected, :if => :retainage_as_expected?
      transition :retainage_expected => :retainage_unexpected, :unless => :retainage_as_expected?    
      
      transition :markups_added => :complete, :if => :template?
    end
    
    event :accept_costs do
      transition any - :new => :costs_specified
    end
    
    event :accept_markups do
      transition :costs_specified => :markups_added
    end
  end
  
  [:labor_invoiced, :material_invoiced, :invoiced, :labor_retainage, :material_retainage, :retainage].each do |sym|
    self.send(:define_method, sym) do
      #self.lines.inject(0) {|memo,obj| memo + obj.send(sym)}
      self.lines.sum(sym) + self.markup_lines.sum(sym)
    end
  end
  
  def advance!
    self.save! if self.advance
  end
  
  def retainage_as_expected?
    self.lines.each {|l| return false unless l.retainage_as_expected? }
    true
  end
  
  def unassigned_costs?
    !self.project.material_costs.where(:component_id => nil).empty? || !self.project.labor_costs.where(:component_id => nil).empty?
    #self.project.tasks.where('raw_labor_cost > 0 OR raw_material_cost > 0').map{ |task| 
    #  task.unit_cost_estimates.empty? && task.fixed_cost_estimates.empty?
    #}.include?( true ) 
  end
  
  def unbalanced_payments?
    # Reload required!
    self.project.reload
    return false if self.project.payments.empty?
    self.project.payments.map{|p| p.balances?}.include?( false )
  end
  
  protected
  
  def populate_lines
    self.project.component_tree.each do |component|
      self.lines.create!(:component_id => component.id)
      #component.unit_cost_estimates.assigned.each {|uc| self.lines.build(:cost => uc).set_defaults.save! }
      #component.fixed_cost_estimates.assigned.each {|fc| self.lines.build(:cost => fc).set_defaults.save! }
      #component.contracts.each {|c| self.lines.build(:cost => c).set_defaults.save! }
    end
    #self.project.contracts.scoped.without_component.each {|c| self.lines.build(:cost => c).set_defaults.save! }
  end
end
