class Payment < ActiveRecord::Base
  belongs_to :project
  
  has_many :lines, :class_name => 'PaymentLine'
  
  validates_presence_of :project
  
  state_machine :state, :initial => :new do
    # States
    state :new do
    end
    
    state :payment_recorded do
    end
    
    state :complete do
    end
    
    # Events
    event :save_payment do
      transition :new => :payment_recorded
    end
    
    event :save_costs do
      transition :payment_recorded => :complete
    end
  end
end
