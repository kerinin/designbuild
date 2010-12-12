module HasInvoices
  module InstanceMethods
    def labor_percent
      # portion of task's cost's to date which are for labor
      unless self.task.nil? || self.task.blank? || self.task.cost.nil?
        pct = divide_or_nil self.task.labor_cost, self.task.cost
        pct ||= 0
      end
      
      # default to 50%
      pct ||= 50
    end

    def material_percent
      # to ensure these always sum to 100
      100 - self.labor_percent
    end   
  end
end