require File.dirname(__FILE__) + '/../test_helper'

class InvoiceLineTest < ActiveSupport::TestCase
  context "An Invoice Line" do
    setup do
      @l = Factory :laborer, :bill_rate => 1
      @project = Factory :project, :labor_percent_retainage => 10, :material_percent_retainage => 20, :contract_percent_retainage => 30
      @component = Factory :component, :project => @project
      
      # est: 100, cost: 50
      @contract = Factory :contract, :project => @project, :component => @component
      @bid = Factory :bid, :contract => @contract, :raw_cost => 100
      @contract.update(:active_bid => @bid)
      @contrat_invoice = Factory :contract_cost, :contract => @contract, :raw_cost => 50
      
      # est: 100, cost: 10, complete: 50
      @task1 = Factory :task, :project => @project
      @fce1 = Factory :fixed_cost_estimate, :raw_cost => 100, :task => @task1, :component => @component
      @lc1 = Factory :labor_cost, :task => @task1, :percent_complete => 50
      @lcl1 = Factory :labor_cost_line, :labor_cost => @lc1, :laborer => @l, :hours => 10
      
      # est: 1000, cost: 100, complete: 100
      @task2 = Factory :task, :project => @project      
      @fce2 = Factory :fixed_cost_estimate, :raw_cost => 1000, :task => @task2, :component => @component
      @lc2 = Factory :labor_cost, :task => @task2, :percent_complete =>100
      @lcl2 = Factory :labor_cost_line, :labor_cost => @lc2, :laborer => @l, :hours => 100
      
      # est: 10000, cost: 1000
      @task3 = Factory :task, :project => @project
      @fce3 = Factory :fixed_cost_estimate, :raw_cost => 10000, :task => @task3, :component => @component
      @mc1 = Factory :material_cost, :task => @task3, :raw_cost => 1000
      
      # requested: 2, paid: 1
      @p_invoice = Factory :invoice, :project => @project, :date => Date::today - 10
      @p_line = Factory( :invoice_line, 
        :invoice => @p_invoice, 
        :labor_amount_requested => 5, 
        :labor_amount_paid => 1, 
        :labor_retainage => 2, 
        :labor_retained => 1, 
        :material_amount_requested => 50, 
        :material_amount_paid => 10, 
        :material_retainage => 20, 
        :material_retained => 10,
        :contract_amount_requested => 500, 
        :contract_amount_paid => 100, 
        :contract_retainage => 200, 
        :contract_retained => 100,
        :state => 'paid'
      )
  
      @invoice = Factory :invoice, :project => @project
      @obj = Factory :invoice_line, :invoice => @invoice, :component => @component
      
      @fixed_invoice = Factory :invoice, :type => 'fixed_bid', @project => @project
      @fixed_line = Factory :invoice_line, :invoice => @fixed_invoice, :component => @component
      
    end
    
    should "be valid" do
      assert @obj.valid?
    end
    
    should "have values" do
      assert_not_nil @obj.labor_invoiced
      assert_not_nil @obj.material_invoiced
      assert_not_nil @obj.contract_invoiced
      assert_not_nil @obj.invoiced
      
      assert_not_nil @obj.labor_paid
      assert_not_nil @obj.material_paid
      assert_not_nil @obj.contract_paid
      assert_not_nil @obj.paid
      
      assert_not_nil @obj.labor_retainage
      assert_not_nil @obj.material_retainage
      assert_not_nil @obj.contract_retainage
      assert_not_nil @obj.retainage
      
      assert_not_nil @obj.labor_retained
      assert_not_nil @obj.material_retained
      assert_not_nil @obj.contract_retained
      assert_not_nil @obj.retained
      
      assert_not_nil @obj.comment
    end
    
    should "require an invoice" do
      assert_raise ActiveRecord::RecordInvalid do
        Factory :invoice_line, :invoice => nil
      end
    end
    
    should "require a component" do
      assert_raise ActiveRecord::RecordInvalid do
        Factory :invoice_line, :component => nil
      end
    end
    
    should "determine component invoiced" do
      # excludes retainage
      assert_equal 3, @component.labor_invoiced
      assert_equal 30, @component.material_invoiced
      assert_equal 300, @component.contract_invoiced
      assert_equal 333, @component.invoiced
    end

    should "determine component retainage" do
      # excludes retainage
      assert_equal 2, @component.labor_retainage
      assert_equal 20, @component.material_retainage
      assert_equal 200, @component.contract_retainage
      assert_equal 222, @component.retainage
    end
        
    should "determine component paid" do
      assert_equal 1, @component.labor_paid
      assert_equal 10, @component.material_paid
      assert_equal 100, @component.contract_paid
      assert_equal 111, @component.paid 
    end

    should "determine component retainage" do
      assert_equal 1, @component.labor_retained
      assert_equal 10, @component.material_retained
      assert_equal 100, @component.contract_retained
      assert_equal 111, @component.retained
    end
        
    should "default to cost - requested for cost+ component" do
      # this is interesting - should we include previously invoiced amounts that weren't paid?
      # I think not, otherwise we can't add up invoices to see how much we've invoiced total
      # better to include a line 'previously invoiced' to the view

      assert_equal (
        ( @component.labor_cost * (1-@project.labor_percent_retainage_float ) )           # labor cost - retainage
        + ( @component.material_cost * (1-@project.material_percent_retainage_float ) )   # material cost - retainage
        + ( @component.contract_cost * (1-@project.contract_percent_retainage_float ) )   # contract cost - retainage
        - @component.invoiced                                                             # invoiced to date (excluding retainage)
      ), @obj.invoiced
      
      assert_equal (
        ( @component.labor_cost * (@project.labor_percent_retainage_float ) )           # labor retainage
        + ( @component.material_cost * (@project.material_percent_retainage_float ) )   # material retainage
        + ( @component.contract_cost * (@project.contract_percent_retainage_float ) )   # contract retainage
        - @component.retainage                                                          # retainage to date
      ), @obj.retainage
    end
    
    should "determine component percent complete" do
      # combine task % complete, weighting by estimated cost
      # note: this requires that task estimated cost + contract cost sums to component estimated cost
      
      assert_equal ( (
        + (@task1.percent_complete_float * @task1.estimated_cost )              # task % of estimated cost
        + (@task2.percent_complete_float * @task2.estimated_cost )
        ) / (@component.estimated_unit_cost + @component.estimated_fixed_cost)  # non-contract estimate
      ), @component.non_contract_percent_complete
      
      assert_equal (
        @component.contract_invoiced / @component.contract_cost                 # % invoiced
      ), @component.contract_percent_complete
      
      assert_equal ( (
        ( @component.non_contract_percent_complete * (@component.estimated_unit_cost + @component.estimated_fixed_cost))
        + ( @component.contract_percent_complete * @component.estimated_contract_cost )
        ) / @component.estimated_cost
      ), @component.percent_complete
    end
    
    should "default to % complete * estimated - requested for fixed-bid component" do
      assert_equal (
        ( ( @component.non_contract_percent_complete * @component.estimated_labor_cost)       # percent of labor estimate
          * (1-@project.labor_percent_retainage_float ) )                                     # labor retainage
        + ( ( @component.non_contract_percent_complete * @component.estimated_meterial_cost)  # percent of material estimate
          * (1-@project.material_percent_retainage_float ) )                                  # material retainage
        + ( ( @component.contract_percent_complete * @component.estimated_contract_cost)      # percent of contract estimate
          * (1-@project.contract_percent_retainage_float ) )                                  # contract retainage
        - @component.invoiced                                                                 # invoiced to date (excluding retainage)
      ), @obj.invoiced
      
      assert_equal (
        ( ( @component.non_contract_percent_complete * @component.estimated_labor_cost)       # percent of labor estimate
          * (@project.labor_percent_retainage_float ) )                                       # labor retainage
        + ( ( @component.non_contract_percent_complete * @component.estimated_meterial_cost)  # percent of material estimate
          * (@project.material_percent_retainage_float ) )                                    # material retainage
        + ( ( @component.contract_percent_complete * @component.estimated_contract_cost)      # percent of contract estimate
          * (@project.contract_percent_retainage_float ) )                                    # contract retainage
        - @component.retainage                                                                # retainage to date
      ), @obj.retainage
    end
    
    should "determine outstanding balance" do
      assert_equal (
        @obj.component.invoiced - @obj.component.paid
      ), @obj.outstanding
    end
  end
end