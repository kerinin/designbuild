require File.dirname(__FILE__) + '/../test_helper'

class InvoiceLineTest < ActiveSupport::TestCase

  context "Given a T&M Project" do
    setup do
      @l = Factory :laborer, :bill_rate => 1
      @project = Factory :project, :labor_percent_retainage => 10, :material_percent_retainage => 20
    end
 
    context "A Fixed Cost Invoice Line" do
      setup do
        @component = @project.components.create! :name => 'component'
      
        @task = @project.tasks.create! :name => 'task'
        @fce = @component.fixed_cost_estimates.create! :name => 'fixed cost', :raw_cost => 100
        @task.fixed_cost_estimates << @fce
        @lc = @task.labor_costs.create! :percent_complete => 50, :date => Date::today
        @lcl = @lc.line_items.create! :laborer => @l, :hours => 100
        @mc2 = @task.material_costs.create! :raw_cost => 100, :date => Date::today, :supplier => Factory(:supplier)
              
        # requested: 2, paid: 1
        @invoice = @project.invoices.create! :date => Date::today
        @line = @invoice.lines.create!( 
          :cost => @fce, 
          :labor_invoiced => 5, 
          :labor_retainage => 2, 
          :material_invoiced => 50, 
          :material_retainage => 20 
        )
  
        @fce.reload
        #[@project, @component, @task, @fce, @invoice, @line].each {|i| i.reload}

        @new_invoice = @project.invoices.create!
        @obj = @new_invoice.lines.create! :cost => @fce
      
        #[@project, @component, @task, @fce, @invoice, @line, @new_invoice, @obj].each {|i| i.reload}
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
        @obj.set_defaults
        
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
        @component = @project.components.create! :name => 'component'
      
        @task = @project.tasks.create! :name => 'task'
        @q = @component.quantities.create! :name => 'quantity', :value => 1
        @uce = @component.unit_cost_estimates.create! :name => 'unit cost', :quantity => @q, :unit_cost => 100
        @task.unit_cost_estimates << @uce
        @lc = @task.labor_costs.create! :percent_complete => 50, :date => Date::today
        @lcl = @lc.line_items.create! :laborer => @l, :hours => 100
        @mc2 = @task.material_costs.create! :raw_cost => 100, :date => Date::today, :supplier => Factory(:supplier)
              
        # requested: 2, paid: 1
        @invoice = @project.invoices.create! :date => Date::today
        @line = @invoice.lines.create!( 
          :cost => @uce, 
          :labor_invoiced => 5, 
          :labor_retainage => 2, 
          :material_invoiced => 50, 
          :material_retainage => 20 
        )     
  
        #[@project, @component, @q, @uce, @lc, @lcl, @mc, @invoice, @line].each {|i| i.reload}

        @new_invoice = @project.invoices.create!
        @obj = @new_invoice.lines.create! :cost => @uce
      
        #[@project, @component, @q, @uce, @lc, @lcl, @mc, @invoice, @line, @new_invoice, @obj].each {|i| i.reload}
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
        @obj.set_defaults
        
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
        @component = @project.components.create! :name => 'component'
      
        @contract = @project.contracts.create! :name => 'contract'
        @component.contracts << @contract
        @bid = @contract.bids.create! :raw_cost => 100, :contractor => 'contractor', :date => Date::today
        @contract.update_attributes :active_bid => @bid
        #puts "start"
        @contract_cost = @contract.costs.create! :raw_cost => 50, :date => Date::today
        #puts "end"
        #puts @contract.raw_cost
        #puts @contract.cost
        
        # requested: 2, paid: 1
        @invoice = @project.invoices.create! :date => Date::today
        @line = @invoice.lines.create!( 
          :cost => @contract, 
          :labor_invoiced => 5, 
          :labor_retainage => 2, 
          :material_invoiced => 50, 
          :material_retainage => 20 
        )     
        
        @contract.reload
        #[@project, @component, @bid, @contract, @contract_cost, @invoice, @line].each {|i| i.reload}

        @new_invoice = @project.invoices.create!
        @obj = @new_invoice.lines.create! :cost => @contract
      
        #[@project, @component, @bid, @contract, @contract_cost, @invoice, @line, @new_invoice, @obj].each {|i| i.reload}
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
        @obj.set_defaults
        #assert_equal 50, @contract_cost.raw_cost
        #assert_contains @contract.costs, @contract_cost
        #assert_not_nil @contract.cost
        
        
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
        @component = @project.components.create! :name => 'component'
      
        @task = @project.tasks.create! :name => 'task'
        @fce = @component.fixed_cost_estimates.create! :name => 'fixed cost', :raw_cost => 100
        @task.fixed_cost_estimates << @fce
        @lc = @task.labor_costs.create! :percent_complete => 50, :date => Date::today
        @lcl = @lc.line_items.create! :laborer => @l, :hours => 100
        @mc2 = @task.material_costs.create! :raw_cost => 100, :date => Date::today, :supplier => Factory(:supplier)
              
        # requested: 2, paid: 1
        @invoice = @project.invoices.create! :date => Date::today
        @line = @invoice.lines.create!( 
          :cost => @fce, 
          :labor_invoiced => 5, 
          :labor_retainage => 2, 
          :material_invoiced => 50, 
          :material_retainage => 20 
        )
  
        @fce.reload
        #[@project, @component, @task, @fce, @invoice, @line].each {|i| i.reload}

        @new_invoice = @project.invoices.create!
        @obj = @new_invoice.lines.create! :cost => @fce
      
        #[@project, @component, @task, @fce, @invoice, @line, @new_invoice, @obj].each {|i| i.reload}
      end

      should "default to % complete * estimated - requested" do
        # for now splitting based on task labor/material COSTS

        @obj.set_defaults
        
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
        @component = @project.components.create! :name => 'component'
      
        @task = @project.tasks.create! :name => 'task'
        @q = @component.quantities.create! :name => 'quantity', :value => 1
        @uce = @component.unit_cost_estimates.create! :name => 'unit cost', :quantity => @q, :unit_cost => 100
        @task.unit_cost_estimates << @uce
        @lc = @task.labor_costs.create! :percent_complete => 50, :date => Date::today
        @lcl = @lc.line_items.create! :laborer => @l, :hours => 100
        @mc2 = @task.material_costs.create! :raw_cost => 100, :date => Date::today, :supplier => Factory(:supplier)
              
        # requested: 2, paid: 1
        @invoice = @project.invoices.create! :date => Date::today
        @line = @invoice.lines.create!( 
          :cost => @uce, 
          :labor_invoiced => 5, 
          :labor_retainage => 2, 
          :material_invoiced => 50, 
          :material_retainage => 20 
        )     
  
        #[@project, @component, @q, @uce, @lc, @lcl, @mc, @invoice, @line].each {|i| i.reload}

        @new_invoice = @project.invoices.create!
        @obj = @new_invoice.lines.create! :cost => @uce
      
        #[@project, @component, @q, @uce, @lc, @lcl, @mc, @invoice, @line, @new_invoice, @obj].each {|i| i.reload}
      end

      should "default to % complete * estimated - requested" do
        # for now splitting based on task labor/material COSTS

        @obj.set_defaults
        
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
        @component = @project.components.create! :name => 'component'
      
        @contract = @project.contracts.create! :name => 'contract'
        @component.contracts << @contract
        @bid = @contract.bids.create! :raw_cost => 100, :contractor => 'contractor', :date => Date::today
        @contract.update_attributes :active_bid => @bid
        @contract_cost = @contract.costs.create! :raw_cost => 50, :date => Date::today
        
        # requested: 2, paid: 1
        @invoice = @project.invoices.create! :date => Date::today
        @line = @invoice.lines.create!( 
          :cost => @contract, 
          :labor_invoiced => 5, 
          :labor_retainage => 2, 
          :material_invoiced => 50, 
          :material_retainage => 20 
        )     
  
        #[@project, @component, @bid, @contract, @contract_cost, @invoice, @line].each {|i| i.reload}

        @new_invoice = @project.invoices.create!
        @obj = @new_invoice.lines.create! :cost => @contract
      
        #[@project, @component, @bid, @contract, @contract_cost, @invoice, @line, @new_invoice, @obj].each {|i| i.reload}
      end

      should "default to % complete * estimated - requested" do
        # for now splitting based on task labor/material COSTS
        
        @obj.set_defaults

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
