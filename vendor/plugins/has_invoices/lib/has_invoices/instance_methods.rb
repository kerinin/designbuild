module HasInvoices
  module InstanceMethods
    def labor_percent
      # portion of task's cost's to date which are for labor
      unless !self.respond_to?(:task) || self.task.nil? || self.task.blank? || self.task.cost.nil?
        pct = multiply_or_nil 100, divide_or_nil( self.task.labor_cost, self.task.cost )
        pct ||= 0
      end
      
      # default to 50%
      pct ||= 50
    end

    def material_percent
      # to ensure these always sum to 100
      100 - self.labor_percent
    end   
    
    [:labor_percent, :material_percent].each do |sym|
      self.send(:define_method, "#{sym}_float") do
        divide_or_nil self.send(sym), 100
      end
    end
    
    def labor_outstanding
      self.labor_invoiced - self.labor_paid
    end
    
    def labor_outstanding_before(date = Date::today)
      self.labor_invoiced_before(date) - self.labor_paid_before(date)
    end
    
    def material_outstanding
      self.material_invoiced - self.material_paid
    end
    
    def material_outstanding_before(date = Date::today)
      self.material_invoiced_before(date) - self.material_paid_before(date)
    end
    
    def outstanding
      self.labor_outstanding + self.material_outstanding
    end
    
    def outstanding_before(date = Date::today)
      self.labor_outstanding_before(date) + self.material_outstanding_before(date)
    end
  end
end
