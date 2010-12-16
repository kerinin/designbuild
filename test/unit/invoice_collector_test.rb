require File.dirname(__FILE__) + '/../test_helper'

class InvoiceCollectorTest < ActiveSupport::TestCase
  context "An invoice collector" do
    setup do
      @l = Factory :laborer, :bill_rate => 1
      @project = Factory :project
      @component = Factory :component, :project => @project
      @task = Factory :task, :project => @project
      @fce = Factory :fixed_cost_estimate, :component => @component, :raw_cost => 200, :task => @task
      
      @contract = Factory :contract, :project => @project, :component => @component
      
      @lc1 = Factory :labor_cost, :task => @task, :date => Date::today
      @lcl1 = Factory :labor_cost_line, :labor_set => @lc1, :hours => 1, :laborer => @l
      @mc1 = Factory :material_cost, :task => @task, :raw_cost => 10, :date => Date::today
      @cc1 = Factory :contract_cost, :contract => @contract, :raw_cost => 200, :date => Date::today
      
      @lc2 = Factory :labor_cost, :task => @task, :date => Date::today - 10
      @lcl2 = Factory :labor_cost_line, :labor_set => @lc2, :hours => 1000, :laborer => @l
      @mc2 = Factory :material_cost, :task => @task, :raw_cost => 10000, :date => Date::today - 10
      @cc2 = Factory :contract_cost, :contract => @contract, :raw_cost => 200000, :date => Date::today - 10
            
      [@l, @project, @component, @fce, @task, @contract].each {|i| i.reload}
      [@lc1, @lcl1, @mc1, @cc1, @lc2, @lcl2, @mc2, @cc2].each {|i| i.reload}
    end
    
    should "aggregate labor cost" do
      assert_equal 101101, @project.labor_cost
      assert_equal 101101, @component.labor_cost
    end
    
    should "aggregate material cost" do
      assert_equal 110110, @project.material_cost
      assert_equal 110110, @component.material_cost
    end
    
    context "with invoices & payments" do
      setup do
        @targets = [@fce, @contract]
        @i1 = Factory :invoice, :project => @project, :date => Date::today
        @i1.lines = @targets.map { |target|
          Factory( :invoice_line, 
          :invoice => @i1,
          :cost => target,
          :labor_invoiced => 2,
          :material_invoiced => 20,
          :labor_retainage => 200,
          :material_retainage => 2000
        ) }
        @i1 = Factory :invoice, :project => @project, :date => Date::today - 5
        @i1.lines = @targets.map { |target|
          Factory( :invoice_line, 
          :invoice => @i1,
          :cost => target,
          :labor_invoiced => 2000,
          :material_invoiced => 20000,
          :labor_retainage => 200000,
          :material_retainage => 2000000
        ) }
        @p1 = Factory :payment, :project => @project, :date => Date::today
        @p1.lines = @targets.map { |target|
          Factory( :payment_line,
          :payment => @p1,
          :cost => target,
          :labor_paid => 3,
          :material_paid => 30,
          :labor_retained => 300,
          :material_retained => 3000
        ) }
        @p2 = Factory :payment, :project => @project, :date => Date::today - 5
        @p2.lines = @targets.map { |target|
          Factory( :payment_line,
          :payment => @p2,
          :cost => target,
          :labor_paid => 3000,
          :material_paid => 30000,
          :labor_retained => 300000,
          :material_retained => 3000000
        ) }
      end
        
      should "aggregate labor invoiced" do
        assert_equal 4004, @project.labor_invoiced
        assert_equal 4004, @component.labor_invoiced
      end
      
      should "aggregate material invoiced" do
        assert_equal 40040, @project.material_invoiced
        assert_equal 40040, @component.material_invoiced
      end
      
      should "aggregate invoiced" do
        assert_equal 44044, @project.invoiced
        assert_equal 44044, @component.invoiced
      end
      
      should "aggregate labor retainage" do
        assert_equal 400400, @project.labor_retainage
        assert_equal 400400, @component.labor_retainage
      end
      
      should "aggregate material retainage" do
        assert_equal 4004000, @project.material_retainage
        assert_equal 4004000, @component.material_retainage
      end
      
      should "aggregate retainage" do
        assert_equal 4404400, @project.retainage
        assert_equal 4404400, @component.retainage
      end
      
      should "aggregate labor paid" do
        assert_equal 6006, @project.labor_paid
        assert_equal 6006, @component.labor_paid
      end
      
      should "aggregate material paid" do
        assert_equal 60060, @project.material_paid
        assert_equal 60060, @component.material_paid
      end
      
      should "aggregate paid" do
        assert_equal 66066, @project.paid
        assert_equal 66066, @component.paid
      end
      
      should "aggregate labor retained" do
        assert_equal 600600, @project.labor_retained
        assert_equal 600600, @component.labor_retained
      end
      
      should "aggregate material retained" do
        assert_equal 6006000, @project.material_retained
        assert_equal 6006000, @component.material_retained
      end
      
      should "aggregate retained" do
        assert_equal 6606600, @project.retained
        assert_equal 6606600, @component.retained
      end
      
      should "aggregate labor outstanding" do
        assert_equal 4004-6006, @project.labor_outstanding
        assert_equal 4004-6006, @component.labor_outstanding
      end
      
      should "aggregate material outstanding" do
        assert_equal 40040-60060, @project.material_outstanding
        assert_equal 40040-60060, @component.material_outstanding
      end
      
      should "aggregate outstanding" do
        assert_equal (4004-6006) + (40040-60060), @project.outstanding
        assert_equal (4004-6006) + (40040-60060), @component.outstanding
      end
    end
  end

  context "An invoice collector with cutoff date" do
    setup do
      @l = Factory :laborer, :bill_rate => 1
      @project = Factory :project
      @component = Factory :component, :project => @project
      @task = Factory :task, :project => @project
      @fce = Factory :fixed_cost_estimate, :component => @component, :raw_cost => 200, :task => @task
      
      @contract = Factory :contract, :project => @project, :component => @component
      
      @lc1 = Factory :labor_cost, :task => @task, :date => Date::today
      @lcl1 = Factory :labor_cost_line, :labor_set => @lc1, :hours => 1, :laborer => @l
      @mc1 = Factory :material_cost, :task => @task, :raw_cost => 10, :date => Date::today
      @cc1 = Factory :contract_cost, :contract => @contract, :raw_cost => 200, :date => Date::today
      
      @lc2 = Factory :labor_cost, :task => @task, :date => Date::today - 10
      @lcl2 = Factory :labor_cost_line, :labor_set => @lc2, :hours => 1000, :laborer => @l
      @mc2 = Factory :material_cost, :task => @task, :raw_cost => 10000, :date => Date::today - 10
      @cc2 = Factory :contract_cost, :contract => @contract, :raw_cost => 200000, :date => Date::today - 10
            
      [@l, @project, @component, @fce, @task, @contract].each {|i| i.reload}
      [@lc1, @lcl1, @mc1, @cc1, @lc2, @lcl2, @mc2, @cc2].each {|i| i.reload}
    end
    
    should "aggregate labor cost" do
      assert_equal 101000, @project.labor_cost_before(Date::today - 5)
      assert_equal 101000, @component.labor_cost_before(Date::today - 5)
    end
    
    should "aggregate material cost" do
      assert_equal 110000, @project.material_cost_before(Date::today - 5)
      assert_equal 110000, @component.material_cost_before(Date::today - 5)
    end
    
    context "with invoices & payments" do
      setup do
        @targets = [@fce, @contract]
        @i1 = Factory :invoice, :project => @project, :date => Date::today
        @i1.lines = @targets.map { |target|
          Factory( :invoice_line, 
          :invoice => @i1,
          :cost => target,
          :labor_invoiced => 2,
          :material_invoiced => 20,
          :labor_retainage => 200,
          :material_retainage => 2000
        ) }
        @i1 = Factory :invoice, :project => @project, :date => Date::today - 10
        @i1.lines = @targets.map { |target|
          Factory( :invoice_line, 
          :invoice => @i1,
          :cost => target,
          :labor_invoiced => 2000,
          :material_invoiced => 20000,
          :labor_retainage => 200000,
          :material_retainage => 2000000
        ) }
        @p1 = Factory :payment, :project => @project, :date => Date::today
        @p1.lines = @targets.map { |target|
          Factory( :payment_line,
          :payment => @p1,
          :cost => target,
          :labor_paid => 3,
          :material_paid => 30,
          :labor_retained => 300,
          :material_retained => 3000
        ) }
        @p2 = Factory :payment, :project => @project, :date => Date::today - 10
        @p2.lines = @targets.map { |target|
          Factory( :payment_line,
          :payment => @p2,
          :cost => target,
          :labor_paid => 3000,
          :material_paid => 30000,
          :labor_retained => 300000,
          :material_retained => 3000000
        ) }
      end
        
      should "aggregate labor invoiced" do
        assert_equal 4000, @project.labor_invoiced_before(Date::today - 5)
        assert_equal 4000, @component.labor_invoiced_before(Date::today - 5)
      end
      
      should "aggregate material invoiced" do
        assert_equal 40000, @project.material_invoiced_before(Date::today - 5)
        assert_equal 40000, @component.material_invoiced_before(Date::today - 5)
      end
      
      should "aggregate invoiced" do
        assert_equal 44000, @project.invoiced_before(Date::today - 5)
        assert_equal 44000, @component.invoiced_before(Date::today - 5)
      end
      
      should "aggregate labor retainage" do
        assert_equal 400000, @project.labor_retainage_before(Date::today - 5)
        assert_equal 400000, @component.labor_retainage_before(Date::today - 5)
      end
      
      should "aggregate material retainage" do
        assert_equal 4000000, @project.material_retainage_before(Date::today - 5)
        assert_equal 4000000, @component.material_retainage_before(Date::today - 5)
      end
      
      should "aggregate retainage" do
        assert_equal 4400000, @project.retainage_before(Date::today - 5)
        assert_equal 4400000, @component.retainage_before(Date::today - 5)
      end
      
      should "aggregate labor paid" do
        assert_equal 6000, @project.labor_paid_before(Date::today - 5)
        assert_equal 6000, @component.labor_paid_before(Date::today - 5)
      end
      
      should "aggregate material paid" do
        assert_equal 60000, @project.material_paid_before(Date::today - 5)
        assert_equal 60000, @component.material_paid_before(Date::today - 5)
      end
      
      should "aggregate paid" do
        assert_equal 66000, @project.paid_before(Date::today - 5)
        assert_equal 66000, @component.paid_before(Date::today - 5)
      end
      
      should "aggregate labor retained" do
        assert_equal 600000, @project.labor_retained_before(Date::today - 5)
        assert_equal 600000, @component.labor_retained_before(Date::today - 5)
      end
      
      should "aggregate material retained" do
        assert_equal 6000000, @project.material_retained_before(Date::today - 5)
        assert_equal 6000000, @component.material_retained_before(Date::today - 5)
      end
      
      should "aggregate retained" do
        assert_equal 6600000, @project.retained_before(Date::today - 5)
        assert_equal 6600000, @component.retained_before(Date::today - 5)
      end
      
      should "aggregate labor outstanding" do
        assert_equal 4000-6000, @project.labor_outstanding_before(Date::today - 5)
        assert_equal 4000-6000, @component.labor_outstanding_before(Date::today - 5)
      end
      
      should "aggregate material outstanding" do
        assert_equal 40000-60000, @project.material_outstanding_before(Date::today - 5)
        assert_equal 40000-60000, @component.material_outstanding_before(Date::today - 5)
      end
      
      should "aggregate outstanding" do
        assert_equal (4000-6000) + (40000-60000), @project.outstanding_before(Date::today - 5)
        assert_equal (4000-6000) + (40000-60000), @component.outstanding_before(Date::today - 5)
      end
    end
  end  
end
