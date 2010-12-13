require File.dirname(__FILE__) + '/../test_helper'

class PaymentLineTest < ActiveSupport::TestCase
  context "An Payment Line" do
    setup do
      @l = Factory :laborer, :bill_rate => 1
      @project = Factory :project, :labor_percent_retainage => 10, :material_percent_retainage => 20
      @component = Factory :component, :project => @project
      
      # est: 100, cost: 50
      @contract = Factory :contract, :project => @project, :component => @component
      @bid = Factory :bid, :contract => @contract, :raw_cost => 100
      @contract.update_attributes(:active_bid => @bid)
      @contrat_payment = Factory :contract_cost, :contract => @contract, :raw_cost => 50
      
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
      @p_payment = Factory :payment, :project => @project, :date => Date::today - 10, :state => 'paid'
      @p_line = Factory( :payment_line, 
        :payment => @p_payment,
        :cost => @fce4, 
        :labor_paid => 1, 
        :labor_retained => 1, 
        :material_paid => 10, 
        :material_retained => 10
      )
  
      [@project, @component, @contract, @bid, @task1, @lc1, @task2, @lc2, @task3, @task4, @fce4, @lc3, @mc2, @p_line, @p_payment].each {|i| i.reload}

      @payment = Factory :payment, :project => @project
      @obj = Factory :payment_line, :payment => @payment, :cost => @fce4
      
      [@obj, @project, @component, @contract, @bid, @task1, @lc1, @task2, @lc2, @task3, @task4, @fce4, @lc3, @mc2, @p_line, @p_payment, @payment].each {|i| i.reload}
    end

    should "be valid" do
      assert @obj.valid?
    end
    
    should "require an payment" do
      assert_raise ActiveRecord::RecordInvalid do
        Factory :payment_line, :payment => nil
      end
    end
    
    should "require a component" do
      assert_raise ActiveRecord::RecordInvalid do
        Factory :payment_line, :cost => nil
      end
    end
      
    should_eventually "default to something" do

    end
 
    should_eventually "determine outstanding balance" do

    end

  end
  context "A Fixed-Bid Payment Line" do
    setup do
      @l = Factory :laborer, :bill_rate => 1
      @project = Factory :project, :fixed_bid => true, :labor_percent_retainage => 10, :material_percent_retainage => 20
      @component = Factory :component, :project => @project
      
      # est: 100, cost: 50
      @contract = Factory :contract, :project => @project, :component => @component
      @bid = Factory :bid, :contract => @contract, :raw_cost => 100
      @contract.update_attributes(:active_bid => @bid)
      @contrat_payment = Factory :contract_cost, :contract => @contract, :raw_cost => 50
      
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
      @p_payment = Factory :payment, :project => @project, :date => Date::today - 10, :state => 'paid'
      
      # NOTE: this needs to be distributed to costs
      
      @p_line = Factory( :payment_line, 
        :payment => @p_payment,
        :cost => @fce4, 
        :labor_paid => 1, 
        :labor_retained => 1, 
        :material_paid => 10, 
        :material_retained => 10
      )
  
      [@project, @component, @contract, @bid, @task1, @lc1, @task2, @lc2, @task3, @task4, @fce4, @lc3, @mc2, @p_line, @p_payment].each {|i| i.reload}

      @payment = Factory :payment, :project => @project
      @obj = Factory :payment_line, :payment => @payment, :cost => @fce4
      
      [@obj, @project, @component, @contract, @bid, @task1, @lc1, @task2, @lc2, @task3, @task4, @fce4, @lc3, @mc2, @p_line, @p_payment, @payment].each {|i| i.reload}
    end
    
    should_eventually "default to something" do
  
    end
  end
end
