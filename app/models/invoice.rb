class Invoice < ActiveRecord::Base
  belongs_to :project
  
  has_many :lines, :class_name => 'InvoiceLine'
  
  validates_presence_of :project
  
  state_machine :state, :initial => :new do
    # States
    state :new do
    end
    
    state :date_set do
    end
    
    state :costs_specified do
    end
    
    state :template_chosen do
    end
    
    state :invoiced do
    end
    
    state :partially_paid do
    end
    
    state :fully_paid do
    end
    
    state :cancelled do
    end
    
    # Events
    event :save_date do
      transition :new => :date_set
    end
    
    event :save_costs do
      transition :date_set => :costs_specified
    end
    
    event :invoice do
      transition :costs_specified => :invoiced
    end
    
    event :record_payment do
      transition [:invoiced, :partially_paid] => :partially_paid, :if => outstanding == 0
      transition [:invoiced, :partially_paid] => :fully_paid, :unless => outstanding == 0
    end
    
    event :cancel do
      transition all => :cancelled
    end
  end
end
