require File.dirname(__FILE__) + '/../test_helper'

class InvoiceLineTest < ActiveSupport::TestCase
  context "An Invoice Line" do
    setup do
      @l = Factory :laborer, :bill_rate => 1
      @project = Factory :project, :labor_percent_retainage => 10, :material_percent_retainage => 20
      @component = Factory :component, :project => @project
      
      # est: 100, cost: 50
      @contract = Factory :contract, :project => @project, :component => @component
      @bid = Factory :bid, :contract => @contract, :raw_cost => 100
      @contract.update_attributes(:active_bid => @bid)
      @contrat_invoice = Factory :contract_cost, :contract => @contract, :raw_cost => 50
      
      # est: 100, cost: 10, complete: 50
      @task1 = Factory :task, :project => @project
      @fce1 = Factory :fixed_cost_estimate, :raw_cost => 100, :task => @task1, :component => @component
      @lc1 = Factory :labor_cost, :task => @task1, :percent_complete => 50
      @lcl1 = Factory :labor_cost_line, :labor_set => @lc1, :laborer => @l, :hours => 10
      
      # est: 1000, cost: 100, complete: 100
      @task2 = Factory :task, :project => @project      
      @fce2 = Factory :fixed_cost_estimate, :raw_cost => 1000, :task => @task2, :component => @component
      @lc2 = Factory :labor_cost, :task => @task2, :percent_complete =>100
      @lcl2 = Factory :labor_cost_line, :labor_set => @lc2, :laborer => @l, :hours => 100
      
      # est: 10000, cost: 1000
      @task3 = Factory :task, :project => @project
      @fce3 = Factory :fixed_cost_estimate, :raw_cost => 10000, :task => @task3, :component => @component
      @mc1 = Factory :material_cost, :task => @task3, :raw_cost => 1000
      
      @task4 = Factory :task, :project => @project
      @fce4 = Factory :fixed_cost_estimate, :raw_cost => 100, :task => @task4, :component => @component
      @lc3 = Factory :labor_cost, :task => @task4, :percent_complete => 50
      @lcl3 = Factory :labor_cost_line, :labor_set => @lc3, :laborer => @l, :hours => 100
      @mc2 = Factory :material_cost, :task => @task4, :raw_cost => 100
      
      # requested: 2, paid: 1
      @p_invoice = Factory :invoice, :project => @project, :date => Date::today - 10
      @p_line = Factory( :invoice_line, 
        :invoice => @p_invoice,
        :cost => @fce4, 
        :labor_invoiced => 5, 
        :labor_retainage => 2, 
        :material_invoiced => 50, 
        :material_retainage => 20 
      )
  
      [@project, @component, @contract, @bid, @task1, @lc1, @task2, @lc2, @task3, @task4, @fce4, @lc3, @mc2, @p_line, @p_invoice].each {|i| i.reload}

      @invoice = Factory :invoice, :project => @project
      @obj = Factory :invoice_line, :invoice => @invoice, :cost => @fce4
      
      [@obj, @project, @component, @contract, @bid, @task1, @lc1, @task2, @lc2, @task3, @task4, @fce4, @lc3, @mc2, @p_line, @p_invoice, @invoice].each {|i| i.reload}
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
      assert_equal (@fce4.labor_cost*(1-@project.labor_percent_retainage_float)-@p_line.labor_invoiced), @obj.labor_invoiced
      assert_equal (@fce4.material_cost*(1-@project.material_percent_retainage_float)-@p_line.material_invoiced), @obj.material_invoiced
      
      assert_equal ( @obj.labor_invoiced + @obj.material_invoiced ), @obj.invoiced

      assert_equal (@fce4.labor_cost*(@project.labor_percent_retainage_float)-@p_line.labor_retainage), @obj.labor_retainage
      assert_equal (@fce4.material_cost*(@project.material_percent_retainage_float)-@p_line.material_retainage), @obj.material_retainage
      
      assert_equal ( @obj.labor_retainage + @obj.material_retainage ), @obj.retainage
    end
 
    should_eventually "determine outstanding balance" do
      assert_equal (
        @obj.cost.invoiced - @obj.cost.paid
      ), @obj.outstanding
    end

  end
  context "A Fixed-Bid Invoice Line" do
    setup do
      @l = Factory :laborer, :bill_rate => 1
      @project = Factory :project, :fixed_bid => true, :labor_percent_retainage => 10, :material_percent_retainage => 20
      @component = Factory :component, :project => @project
      
      # est: 100, cost: 50
      @contract = Factory :contract, :project => @project, :component => @component
      @bid = Factory :bid, :contract => @contract, :raw_cost => 100
      @contract.update_attributes(:active_bid => @bid)
      @contrat_invoice = Factory :contract_cost, :contract => @contract, :raw_cost => 50
      
      # est: 100, cost: 10, complete: 50
      @task1 = Factory :task, :project => @project
      @fce1 = Factory :fixed_cost_estimate, :raw_cost => 100, :task => @task1, :component => @component
      @lc1 = Factory :labor_cost, :task => @task1, :percent_complete => 50
      @lcl1 = Factory :labor_cost_line, :labor_set => @lc1, :laborer => @l, :hours => 10
      
      # est: 1000, cost: 100, complete: 100
      @task2 = Factory :task, :project => @project      
      @fce2 = Factory :fixed_cost_estimate, :raw_cost => 1000, :task => @task2, :component => @component
      @lc2 = Factory :labor_cost, :task => @task2, :percent_complete =>100
      @lcl2 = Factory :labor_cost_line, :labor_set => @lc2, :laborer => @l, :hours => 100
      
      # est: 10000, cost: 1000
      @task3 = Factory :task, :project => @project
      @fce3 = Factory :fixed_cost_estimate, :raw_cost => 10000, :task => @task3, :component => @component
      @mc1 = Factory :material_cost, :task => @task3, :raw_cost => 1000
      
      @task4 = Factory :task, :project => @project
      @fce4 = Factory :fixed_cost_estimate, :raw_cost => 100, :task => @task4, :component => @component
      @lc3 = Factory :labor_cost, :task => @task4, :percent_complete => 50
      @lcl3 = Factory :labor_cost_line, :labor_set => @lc3, :laborer => @l, :hours => 100
      @mc2 = Factory :material_cost, :task => @task4, :raw_cost => 100
      
      
      # requested: 2, paid: 1
      @p_invoice = Factory :invoice, :project => @project, :date => Date::today - 10
      
      # NOTE: this needs to be distributed to costs
      
      @p_line = Factory( :invoice_line, 
        :invoice => @p_invoice,
        :cost => @fce4, 
        :labor_invoiced => 5, 
        :labor_retainage => 2, 
        :material_invoiced => 50, 
        :material_retainage => 20
      )
  
      [@project, @component, @contract, @bid, @task1, @lc1, @task2, @lc2, @task3, @task4, @fce4, @lc3, @mc2, @p_line, @p_invoice].each {|i| i.reload}

      @invoice = Factory :invoice, :project => @project
      @obj = Factory :invoice_line, :invoice => @invoice, :cost => @fce4
      
      [@obj, @project, @component, @contract, @bid, @task1, @lc1, @task2, @lc2, @task3, @task4, @fce4, @lc3, @mc2, @p_line, @p_invoice, @invoice].each {|i| i.reload}
    end
    
    should "default to % complete * estimated - requested" do
      # for now splitting based on task labor/material costs

      # % complete * labor multiplier * estimated cost, minus retainage
      assert_equal (
        @fce4.labor_percent_float * @fce4.task.percent_complete_float * @fce4.estimated_cost *
        (1-@project.labor_percent_retainage_float )
      ) - @p_line.labor_invoiced, @obj.labor_invoiced
      assert_equal (
        @fce4.material_percent_float * @fce4.task.percent_complete_float * @fce4.estimated_cost *
        (1-@project.material_percent_retainage_float )
      ) - @p_line.material_invoiced, @obj.material_invoiced      

      assert_equal (
        @fce4.labor_percent_float * @fce4.task.percent_complete_float * @fce4.estimated_cost *
        (@project.labor_percent_retainage_float )
      ) - @p_line.labor_retainage, @obj.labor_retainage
      assert_equal (
        @fce4.material_percent_float * @fce4.task.percent_complete_float * @fce4.estimated_cost *
        (@project.material_percent_retainage_float )
      ) - @p_line.material_retainage, @obj.material_retainage    
    end
  end
end
