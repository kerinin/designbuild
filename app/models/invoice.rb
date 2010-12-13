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
    
    state :complete do
    end
    
    # Events
    event :save_date do
      transition :new => :date_set
    end
    
    event :save_costs do
      transition :date_set => :costs_specified
    end
    
    event :set_template do
      transition :costs_specified => :complete
    end
  end
end
