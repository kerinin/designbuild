require File.dirname(__FILE__) + '/../test_helper'

class InvoiceLineTest < ActiveSupport::TestCase
  context "Given a T&M Project" do
    setup do
      @l = Factory :laborer, :bill_rate => 1
      @project = Factory :project, :labor_percent_retainage => 10, :material_percent_retainage => 20
    end
 
    context "A Fixed Cost Invoice Line" do
      setup do
        @component = Factory :component, :project => @project
      
        @task = Factory :task, :project => @project
        @fce = Factory :fixed_cost_estimate, :raw_cost => 100, :task => @task, :component => @component
        @lc = Factory :labor_cost, :task => @task, :percent_complete => 50, :date => Date::today
        @lcl = Factory :labor_cost_line, :labor_set => @lc, :laborer => @l, :hours => 100
        @mc2 = Factory :material_cost, :task => @task, :raw_cost => 100, :date => Date::today
              
        # requested: 2, paid: 1
        @invoice = Factory :invoice, :project => @project, :date => Date::today
        @line = Factory( :invoice_line, 
          :invoice => @invoice,
          :cost => @fce, 
          :labor_invoiced => 5, 
          :labor_retainage => 2, 
          :material_invoiced => 50, 
          :material_retainage => 20 
        )
  
        [@project, @component, @task, @fce, @invoice, @line].each {|i| i.reload}

        @new_invoice = Factory :invoice, :project => @project
        @obj = Factory :invoice_line, :invoice => @new_invoice, :cost => @fce
      
        [@project, @component, @task, @fce, @invoice, @line, @new_invoice, @obj].each {|i| i.reload}
      end

      should "be valid" do
        assert @obj.valid?
      end
    
      should "have values" do
        assert_not_nil @obj.labor_invoiced
        assert_not_nil @obj.material_invoiced
        assert_not_nil @obj.invoiced
      
        assert_not_nil @obj.labor_retainage
        assert_not_nil @obj.material_retainage
        assert_not_nil @obj.retainage
      end
          
      should "require an invoice" do
        assert_raise ActiveRecord::RecordInvalid do
          Factory :invoice_line, :invoice => nil
        end
      end
    
      should "require a cost" do
        assert_raise ActiveRecord::RecordInvalid do
          Factory :invoice_line, :cost => nil
        end
      end
      
      should "default to cost - requested" do
        assert_equal (@fce.labor_cost*(1-@project.labor_percent_retainage_float)-@line.labor_invoiced), @obj.labor_invoiced
        assert_equal (@fce.material_cost*(1-@project.material_percent_retainage_float)-@line.material_invoiced), @obj.material_invoiced
      
        assert_equal ( @obj.labor_invoiced + @obj.material_invoiced ), @obj.invoiced

        assert_equal (@fce.labor_cost*(@project.labor_percent_retainage_float)-@line.labor_retainage), @obj.labor_retainage
        assert_equal (@fce.material_cost*(@project.material_percent_retainage_float)-@line.material_retainage), @obj.material_retainage
      
        assert_equal ( @obj.labor_retainage + @obj.material_retainage ), @obj.retainage
      end
    end
    
    context "A Unit Cost Invoice Line" do
      setup do
        @component = Factory :component, :project => @project
      
        @task = Factory :task, :project => @project
        @q = Factory :quantity, :component => @component, :value => 1
        @uce = Factory :unit_cost_estimate, :quantity => @q, :unit_cost => 100, :task => @task, :component => @component
        @lc = Factory :labor_cost, :task => @task, :percent_complete => 50, :date => Date::today
        @lcl = Factory :labor_cost_line, :labor_set => @lc, :laborer => @l, :hours => 100
        @mc = Factory :material_cost, :task => @task, :raw_cost => 100, :date => Date::today
      
        # requested: 2, paid: 1
        @invoice = Factory :invoice, :project => @project, :date => Date::today
        @line = Factory( :invoice_line, 
          :invoice => @invoice,
          :cost => @uce, 
          :labor_invoiced => 5, 
          :labor_retainage => 2, 
          :material_invoiced => 50, 
          :material_retainage => 20 
        )
  
        [@project, @component, @q, @uce, @lc, @lcl, @mc, @invoice, @line].each {|i| i.reload}

        @new_invoice = Factory :invoice, :project => @project
        @obj = Factory :invoice_line, :invoice => @new_invoice, :cost => @uce
      
        [@project, @component, @q, @uce, @lc, @lcl, @mc, @invoice, @line, @new_invoice, @obj].each {|i| i.reload}
      end

      should "be valid" do
        assert @obj.valid?
      end
    
      should "have values" do
        assert_not_nil @obj.labor_invoiced
        assert_not_nil @obj.material_invoiced
        assert_not_nil @obj.invoiced
      
        assert_not_nil @obj.labor_retainage
        assert_not_nil @obj.material_retainage
        assert_not_nil @obj.retainage
      end
    
      should "require an invoice" do
        assert_raise ActiveRecord::RecordInvalid do
          Factory :invoice_line, :invoice => nil
        end
      end
    
      should "require a component" do
        assert_raise ActiveRecord::RecordInvalid do
          Factory :invoice_line, :cost => nil
        end
      end
      
      should "default to cost - requested" do
        assert_equal (@uce.labor_cost*(1-@project.labor_percent_retainage_float)-@line.labor_invoiced), @obj.labor_invoiced
        assert_equal (@uce.material_cost*(1-@project.material_percent_retainage_float)-@line.material_invoiced), @obj.material_invoiced
      
        assert_equal ( @obj.labor_invoiced + @obj.material_invoiced ), @obj.invoiced

        assert_equal (@uce.labor_cost*(@project.labor_percent_retainage_float)-@line.labor_retainage), @obj.labor_retainage
        assert_equal (@uce.material_cost*(@project.material_percent_retainage_float)-@line.material_retainage), @obj.material_retainage
      
        assert_equal ( @obj.labor_retainage + @obj.material_retainage ), @obj.retainage
      end
    end

    context "A contract Invoice Line" do
      setup do
        @component = Factory :component, :project => @project
      
        # est: 100, cost: 50
        @contract = Factory :contract, :project => @project, :component => @component
        @bid = Factory :bid, :contract => @contract, :raw_cost => 100
        @contract.update_attributes(:active_bid => @bid)
        @contract_cost = Factory :contract_cost, :contract => @contract, :raw_cost => 50, :date => Date::today

        # requested: 2, paid: 1
        @invoice = Factory :invoice, :project => @project, :date => Date::today
        @line = Factory( :invoice_line, 
          :invoice => @invoice,
          :cost => @contract, 
          :labor_invoiced => 5, 
          :labor_retainage => 2, 
          :material_invoiced => 50, 
          :material_retainage => 20 
        )
  
        [@project, @component, @bid, @contract, @contract_cost, @invoice, @line].each {|i| i.reload}

        @new_invoice = Factory :invoice, :project => @project
        @obj = Factory :invoice_line, :invoice => @new_invoice, :cost => @contract
      
        [@project, @component, @bid, @contract, @contract_cost, @invoice, @line, @new_invoice, @obj].each {|i| i.reload}
      end

      should "be valid" do
        assert @obj.valid?
      end
    
      should "have values" do
        assert_not_nil @obj.labor_invoiced
        assert_not_nil @obj.material_invoiced
        assert_not_nil @obj.invoiced
      
        assert_not_nil @obj.labor_retainage
        assert_not_nil @obj.material_retainage
        assert_not_nil @obj.retainage
      end
    
      should "require an invoice" do
        assert_raise ActiveRecord::RecordInvalid do
          Factory :invoice_line, :invoice => nil
        end
      end
    
      should "require a component" do
        assert_raise ActiveRecord::RecordInvalid do
          Factory :invoice_line, :cost => nil
        end
      end
      
      should "default to cost - requested" do
        assert_equal (0.5*@contract.cost*(1-@project.labor_percent_retainage_float)-@line.labor_invoiced), @obj.labor_invoiced
        assert_equal (0.5*@contract.cost*(1-@project.material_percent_retainage_float)-@line.material_invoiced), @obj.material_invoiced
      
        assert_equal ( @obj.labor_invoiced + @obj.material_invoiced ), @obj.invoiced

        assert_equal (0.5*@contract.cost*(@project.labor_percent_retainage_float)-@line.labor_retainage), @obj.labor_retainage
        assert_equal (0.5*@contract.cost*(@project.material_percent_retainage_float)-@line.material_retainage), @obj.material_retainage
      
        assert_equal ( @obj.labor_retainage + @obj.material_retainage ), @obj.retainage
      end
    end
  end

  context "Given a Fixed-Bid Project" do
    setup do
      @l = Factory :laborer, :bill_rate => 1
      @project = Factory :project, :fixed_bid => true, :labor_percent_retainage => 10, :material_percent_retainage => 20
    end
 
    context "A Fixed Cost Invoice Line" do
      setup do
        @component = Factory :component, :project => @project
      
        @task = Factory :task, :project => @project
        @fce = Factory :fixed_cost_estimate, :raw_cost => 100, :task => @task, :component => @component
        @lc = Factory :labor_cost, :task => @task, :percent_complete => 50, :date => Date::today
        @lcl = Factory :labor_cost_line, :labor_set => @lc, :laborer => @l, :hours => 100
        @mc2 = Factory :material_cost, :task => @task, :raw_cost => 100, :date => Date::today
              
        # requested: 2, paid: 1
        @invoice = Factory :invoice, :project => @project, :date => Date::today
        @line = Factory( :invoice_line, 
          :invoice => @invoice,
          :cost => @fce, 
          :labor_invoiced => 5, 
          :labor_retainage => 2, 
          :material_invoiced => 50, 
          :material_retainage => 20 
        )
  
        [@project, @component, @task, @fce, @invoice, @line].each {|i| i.reload}

        @new_invoice = Factory :invoice, :project => @project
        @obj = Factory :invoice_line, :invoice => @new_invoice, :cost => @fce
      
        [@project, @component, @task, @fce, @invoice, @line, @new_invoice, @obj].each {|i| i.reload}
      end

      should "default to % complete * estimated - requested" do
        # for now splitting based on task labor/material COSTS

        # % complete * labor multiplier * estimated cost, minus retainage
        assert_equal (
          @fce.labor_percent_float * @fce.task.percent_complete_float * @fce.estimated_cost *
          (1-@project.labor_percent_retainage_float )
        ) - @line.labor_invoiced, @obj.labor_invoiced
        assert_equal (
          @fce.material_percent_float * @fce.task.percent_complete_float * @fce.estimated_cost *
          (1-@project.material_percent_retainage_float )
        ) - @line.material_invoiced, @obj.material_invoiced      

        assert_equal (
          @fce.labor_percent_float * @fce.task.percent_complete_float * @fce.estimated_cost *
          (@project.labor_percent_retainage_float )
        ) - @line.labor_retainage, @obj.labor_retainage
        assert_equal (
          @fce.material_percent_float * @fce.task.percent_complete_float * @fce.estimated_cost *
          (@project.material_percent_retainage_float )
        ) - @line.material_retainage, @obj.material_retainage    
      end
    end
    
    context "A Unit Cost Invoice Line" do
      setup do
        @component = Factory :component, :project => @project
      
        @task = Factory :task, :project => @project
        @q = Factory :quantity, :component => @component, :value => 1
        @uce = Factory :unit_cost_estimate, :quantity => @q, :unit_cost => 100, :task => @task, :component => @component
        @lc = Factory :labor_cost, :task => @task, :percent_complete => 50, :date => Date::today
        @lcl = Factory :labor_cost_line, :labor_set => @lc, :laborer => @l, :hours => 100
        @mc = Factory :material_cost, :task => @task, :raw_cost => 100, :date => Date::today
      
        # requested: 2, paid: 1
        @invoice = Factory :invoice, :project => @project, :date => Date::today
        @line = Factory( :invoice_line, 
          :invoice => @invoice,
          :cost => @uce, 
          :labor_invoiced => 5, 
          :labor_retainage => 2, 
          :material_invoiced => 50, 
          :material_retainage => 20 
        )
  
        [@project, @component, @q, @uce, @lc, @lcl, @mc, @invoice, @line].each {|i| i.reload}

        @new_invoice = Factory :invoice, :project => @project
        @obj = Factory :invoice_line, :invoice => @new_invoice, :cost => @uce
      
        [@project, @component, @q, @uce, @lc, @lcl, @mc, @invoice, @line, @new_invoice, @obj].each {|i| i.reload}
      end

      should "default to % complete * estimated - requested" do
        # for now splitting based on task labor/material COSTS

        # % complete * labor multiplier * estimated cost, minus retainage
        # Fun with Floats!
        assert ( (
          @uce.labor_percent_float * @uce.task.percent_complete_float * @uce.estimated_cost *
          (1-@project.labor_percent_retainage_float )
        ) - @line.labor_invoiced - @obj.labor_invoiced  ).abs < 0.00001
        assert ( (
          @uce.material_percent_float * @uce.task.percent_complete_float * @uce.estimated_cost *
          (1-@project.material_percent_retainage_float )
        ) - @line.material_invoiced - @obj.material_invoiced  ).abs < 0.00001  

        assert ( (
          @uce.labor_percent_float * @uce.task.percent_complete_float * @uce.estimated_cost *
          (@project.labor_percent_retainage_float )
        ) - @line.labor_retainage - @obj.labor_retainage  ).abs < 0.00001
        assert ( (
          @uce.material_percent_float * @uce.task.percent_complete_float * @uce.estimated_cost *
          (@project.material_percent_retainage_float )
        ) - @line.material_retainage - @obj.material_retainage ).abs < 0.00001 
      end
    end

    context "A contract Invoice Line" do
      setup do
        @component = Factory :component, :project => @project
      
        # est: 100, cost: 50
        @contract = Factory :contract, :project => @project, :component => @component
        @bid = Factory :bid, :contract => @contract, :raw_cost => 100
        @contract.update_attributes(:active_bid => @bid)
        @contract_cost = Factory :contract_cost, :contract => @contract, :raw_cost => 50, :date => Date::today

        # requested: 2, paid: 1
        @invoice = Factory :invoice, :project => @project, :date => Date::today
        @line = Factory( :invoice_line, 
          :invoice => @invoice,
          :cost => @contract, 
          :labor_invoiced => 5, 
          :labor_retainage => 2, 
          :material_invoiced => 50, 
          :material_retainage => 20 
        )
  
        [@project, @component, @bid, @contract, @contract_cost, @invoice, @line].each {|i| i.reload}

        @new_invoice = Factory :invoice, :project => @project
        @obj = Factory :invoice_line, :invoice => @new_invoice, :cost => @contract
      
        [@project, @component, @bid, @contract, @contract_cost, @invoice, @line, @new_invoice, @obj].each {|i| i.reload}
      end

      should "default to % complete * estimated - requested" do
        # for now splitting based on task labor/material COSTS

        # % complete * labor multiplier * estimated cost, minus retainage
        assert_equal (
          0.5 * @contract.percent_complete_float * @contract.estimated_cost *
          (1-@project.labor_percent_retainage_float )
        ) - @line.labor_invoiced, @obj.labor_invoiced
        assert_equal (
          0.5 * @contract.percent_complete_float * @contract.estimated_cost *
          (1-@project.material_percent_retainage_float )
        ) - @line.material_invoiced, @obj.material_invoiced      

        assert_equal (
          0.5 * @contract.percent_complete_float * @contract.estimated_cost *
          (@project.labor_percent_retainage_float )
        ) - @line.labor_retainage, @obj.labor_retainage
        assert_equal (
          0.5 * @contract.percent_complete_float * @contract.estimated_cost *
          (@project.material_percent_retainage_float )
        ) - @line.material_retainage, @obj.material_retainage    
      end
    end
  end
end
