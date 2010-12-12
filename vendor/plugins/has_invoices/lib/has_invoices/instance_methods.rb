module HasInvoices
  module InstanceMethods
    def labor_percent
      # portion of task's cost's to date which are for labor
      unless self.task.nil? || self.task.blank? || self.task.cost.nil?
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
    
    def invoiced=(value)
      # allows quick setting of invoiced - divides evenly
      self.labor_invoiced = value / 2
      self.material_invoiced = value / 2
    end
  end
end
