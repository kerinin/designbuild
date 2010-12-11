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
      
      # requested: 2, paid: 1
      @p_invoice = Factory :invoice, :project => @project, :date => Date::today - 10, :state => 'paid'
      
      # NOTE: this needs to be distributed to costs
      
      @p_line = Factory( :invoice_line, 
        :invoice => @p_invoice,
        :cost => @fce1, 
        :labor_invoiced => 5, 
        :labor_paid => 1, 
        :labor_retainage => 2, 
        :labor_retained => 1, 
        :material_invoiced => 50, 
        :material_paid => 10, 
        :material_retainage => 20, 
        :material_retained => 10
      )
  
      [@project, @component, @contract, @bid, @task1, @lc1, @task2, @lc2, @task3, @p_line, @p_invoice].each {|i| i.reload}

      @invoice = Factory :invoice, :project => @project
      @obj = Factory :invoice_line, :invoice => @invoice, :cost => @fce1
      
      [@obj, @project, @component, @contract, @bid, @task1, @lc1, @task2, @lc2, @task3, @p_line, @p_invoice, @invoice].each {|i| i.reload}
    end
  
    should "be valid" do
      assert @obj.valid?
    end
    
    should "have values" do
      assert_not_nil @obj.labor_invoiced
      assert_not_nil @obj.material_invoiced
      assert_not_nil @obj.invoiced
      
      assert_not_nil @obj.labor_paid
      assert_not_nil @obj.material_paid
      assert_not_nil @obj.paid
      
      assert_not_nil @obj.labor_retainage
      assert_not_nil @obj.material_retainage
      assert_not_nil @obj.retainage
      
      assert_not_nil @obj.labor_retained
      assert_not_nil @obj.material_retained
      assert_not_nil @obj.retained
    end
    
    should_eventually "require an invoice" do
      assert_raise ActiveRecord::RecordInvalid do
        Factory :invoice_line, :invoice => nil
      end
    end
    
    should_eventually "require a component" do
      assert_raise ActiveRecord::RecordInvalid do
        Factory :invoice_line, :component => nil
      end
    end
      
    should "default to cost - requested" do
      # this is interesting - should we include previously invoiced amounts that weren't paid?
      # I think not, otherwise we can't add up invoices to see how much we've invoiced total
      # better to include a line 'previously invoiced' to the view
      
      assert_equal (@component.labor_cost*(1-@project.labor_percent_retainage_float)-@p_line.labor_invoiced), @obj.labor_invoiced
      assert_equal (@component.material_cost*(1-@project.material_percent_retainage_float)-@p_line.material_invoiced), @obj.material_invoiced
      
      assert_equal ( @obj.labor_invoiced + @obj.material_invoiced ), @obj.invoiced

      assert_equal (@component.labor_cost*(@project.labor_percent_retainage_float)-@p_line.labor_retainage), @obj.labor_retainage
      assert_equal (@component.material_cost*(@project.material_percent_retainage_float)-@p_line.material_retainage), @obj.material_retainage
      
      assert_equal ( @obj.labor_retainage + @obj.material_retainage ), @obj.retainage
    end
 
    should "determine outstanding balance" do
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
      
      # requested: 2, paid: 1
      @p_invoice = Factory :invoice, :project => @project, :date => Date::today - 10, :state => 'paid'
      
      # NOTE: this needs to be distributed to costs
      
      @p_line = Factory( :invoice_line, 
        :invoice => @p_invoice,
        :cost => @fce1, 
        :labor_invoiced => 5, 
        :labor_paid => 1, 
        :labor_retainage => 2, 
        :labor_retained => 1, 
        :material_invoiced => 50, 
        :material_paid => 10, 
        :material_retainage => 20, 
        :material_retained => 10
      )
  
      [@project, @component, @contract, @bid, @task1, @lc1, @task2, @lc2, @task3, @p_line, @p_invoice].each {|i| i.reload}

      @invoice = Factory :invoice, :project => @project
      @obj = Factory :invoice_line, :invoice => @invoice, :cost => @fce1
      
      [@obj, @project, @component, @contract, @bid, @task1, @lc1, @task2, @lc2, @task3, @p_line, @p_invoice, @invoice].each {|i| i.reload}
    end
    
    should "determine task labor percent complete" do
      assert_equal 100, @task1.labor_percent
      assert_equal 100, @task2.labor_percent
      assert_equal 0, @task3.labor_percent
      assert_equal 50, @task4.labor_percent
    end
    
    should "determine task material percent complete" do
      assert_equal 0, @task1.material_percent
      assert_equal 0, @task2.material_percent
      assert_equal 100, @task3.material_percent
      assert_equal 50, @task4.material_percent
    end
    
    should_eventually "default to % complete * estimated - requested" do
      # How to handle not estimating labor & material explicitly?
      # for now splitting based on actual labor/material costs
      
      assert_equal (
        ( ( @component.non_contract_percent_complete * @component.estimated_labor_cost) *      # percent of labor estimate
          (1-@project.labor_percent_retainage_float ) ) +                                    # labor retainage
        ( ( @component.non_contract_percent_complete * @component.estimated_meterial_cost) * # percent of material estimate
          (1-@project.material_percent_retainage_float ) ) +                                 # material retainage
        ( ( @component.contract_percent_complete * @component.estimated_contract_cost) *     # percent of contract estimate
          (1-@project.contract_percent_retainage_float ) ) -                                 # contract retainage
        @component.invoiced                                                                 # invoiced to date (excluding retainage)
      ), @obj.invoiced
      
      assert_equal (
        ( ( @component.non_contract_percent_complete * @component.estimated_labor_cost) *      # percent of labor estimate
          (@project.labor_percent_retainage_float ) ) +                                      # labor retainage
        ( ( @component.non_contract_percent_complete * @component.estimated_meterial_cost) * # percent of material estimate
          (@project.material_percent_retainage_float ) ) +                                   # material retainage
        ( ( @component.contract_percent_complete * @component.estimated_contract_cost) *     # percent of contract estimate
          (@project.contract_percent_retainage_float ) ) -                                   # contract retainage
        @component.retainage                                                                # retainage to date
      ), @obj.retainage
    end
  end
end