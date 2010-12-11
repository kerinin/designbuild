require File.dirname(__FILE__) + '/../test_helper'

class ComponentTest < ActiveSupport::TestCase
  context "A component w/ actual costs" do
    setup do
      @l = Factory :laborer, :bill_rate => 1
      @project = Factory :project
      @obj = Factory :component
      @other = Factory :component
      
      @task = Factory :task
      
      @fc1 = Factory :fixed_cost_estimate, :raw_cost => 5, :component => @obj, :task => @task
      @fc2 = Factory :fixed_cost_estimate, :raw_cost => 50, :component => @obj, :task => @task
      @fc3 = Factory :fixed_cost_estimate, :raw_cost => 500, :component => @obj
      @fc4 = Factory :fixed_cost_estimate, :raw_cost => 5000, :component => @obj
      @fc5 = Factory :fixed_cost_estimate, :raw_cost => 5, :component => @other, :task => @task
      @fc6 = Factory :fixed_cost_estimate, :raw_cost => 50, :component => @other, :task => @task
      
      @q = Factory :quantity, :component => @obj, :value => 1
      @uc1 = Factory :unit_cost_estimate, :component => @obj, :task => @task, :unit_cost => 50000
      @uc2 = Factory :unit_cost_estimate, :component => @obj, :task => @task, :unit_cost => 500000
      @uc3 = Factory :unit_cost_estimate, :component => @other, :task => @task, :unit_cost => 500
      @uc4 = Factory :unit_cost_estimate, :component => @other, :task => @task, :unit_cost => 5000
      @uc5 = Factory :unit_cost_estimate, :component => @obj, :unit_cost => 5000000
      @uc6 = Factory :unit_cost_estimate, :component => @obj, :unit_cost => 50000000
      
      @c1 = Factory :contract, :project => @project, :component => @obj
      @c2 = Factory :contract, :project => @project, :component => @obj
      @c3 = Factory :contract, :project => @project
      @b1 = Factory :bid, :contract => @c1, :raw_cost => 50000
      @b2 = Factory :bid, :contract => @c2, :raw_cost => 500000
      @b3 = Factory :bid, :contract => @c3, :raw_cost => 5000000
      @c1.update_attributes(:active_bid => @b1)
      @c2.update_attributes(:active_bid => @b2)
      @c3.update_attributes(:active_bid => @b3)
      
      @lc1 = Factory :labor_cost, :task => @task, :percent_complete => 50
      @lcl1 = Factory :labor_cost_line, :labor_set => @lc1, :laborer => @l, :hours => 1
      @lc2 = Factory :labor_cost, :task => @task, :percent_complete => 60
      @lcl2 = Factory :labor_cost_line, :labor_set => @lc2, :laborer => @l, :hours => 10
      
      @mc1 = Factory :material_cost, :task => @task, :raw_cost => 100
      @mc2 = Factory :material_cost, :task => @task, :raw_cost => 1000
      
      @cc1 = Factory :contract_cost, :contract => @c1, :raw_cost => 10000
      @cc2 = Factory :contract_cost, :contract => @c2, :raw_cost => 100000
      @cc3 = Factory :contract_cost, :contract => @c3, :raw_cost => 1000000
      
      [@obj, @task, @other, @project, @fc1, @fc2, @fc3, @fc4, @fc5, @fc6, @uc1, @uc2, @uc3, @uc4, @uc5, @uc6, @c1, @c2, @c3, @b1, @b2, @b3, @lc1, @lc2].each {|i| i.reload}

      @p_invoice = Factory :invoice, :project => @project, :date => Date::today - 10, :state => 'paid'
      @p_line = Factory( :invoice_line, 
        :invoice => @p_invoice,
        :component => @obj, 
        :labor_invoiced => 5, 
        :labor_paid => 1, 
        :labor_retainage => 2, 
        :labor_retained => 1, 
        :material_invoiced => 50, 
        :material_paid => 10, 
        :material_retainage => 20, 
        :material_retained => 10,
        :contract_invoiced => 500, 
        :contract_paid => 100, 
        :contract_retainage => 200, 
        :contract_retained => 100
      )
      
      [@obj,@p_invoice, @p_line, @task, @other, @project, @fc1, @fc2, @fc3, @fc4, @fc5, @fc6, @uc1, @uc2, @uc3, @uc4, @uc5, @uc6, @c1, @c2, @c3, @b1, @b2, @b3, @lc1, @lc2].each {|i| i.reload}
    end
    
    should "determine fixed cost" do
      # NOTE: This is assuming that task estimates are uniquely determined by component estimates
      
      assert_equal (@task.labor_cost * @fc1.cost / @task.estimated_cost), @fc1.labor_cost
      assert_equal (@task.labor_cost * @fc2.cost / @task.estimated_cost), @fc2.labor_cost
      assert_equal nil, @fc3.labor_cost
      assert_equal nil, @fc4.labor_cost
      
      assert_equal (@task.material_cost * @fc1.cost / @task.estimated_cost), @fc1.material_cost
      assert_equal (@task.material_cost * @fc2.cost / @task.estimated_cost), @fc2.material_cost
      assert_equal nil, @fc3.material_cost
      assert_equal nil, @fc4.material_cost
    end
   
    should "determine unit cost" do
      assert_equal (@task.labor_cost * @uc1.cost / @task.estimated_cost), @uc1.labor_cost
      assert_equal (@task.labor_cost * @uc2.cost / @task.estimated_cost), @uc2.labor_cost
      assert_equal nil, @uc5.labor_cost
      assert_equal nil, @uc6.labor_cost
      
      assert_equal (@task.material_cost * @uc1.cost / @task.estimated_cost), @uc1.material_cost
      assert_equal (@task.material_cost * @uc2.cost / @task.estimated_cost), @uc2.material_cost
      assert_equal nil, @uc5.material_cost
      assert_equal nil, @uc6.material_cost
    end
 
    should "determine labor cost" do
      fixed_cost = @obj.fixed_cost_estimates.inject(nil) {|memo,obj| add_or_nil memo, obj.labor_cost}
      unit_cost = @obj.unit_cost_estimates.inject(nil) {|memo,obj| add_or_nil memo, obj.labor_cost}
      assert_equal add_or_nil(fixed_cost, unit_cost), @obj.labor_cost
    end
    
    should "determine material cost" do
      fixed_cost = @obj.fixed_cost_estimates.inject(nil) {|memo,obj| add_or_nil memo, obj.material_cost}
      unit_cost = @obj.unit_cost_estimates.inject(nil) {|memo,obj| add_or_nil memo, obj.material_cost}
      assert_equal add_or_nil(fixed_cost, unit_cost), @obj.material_cost
    end
    
    should "determine contract cost" do
      assert_equal @obj.contracts.inject(nil) {|memo,obj| add_or_nil memo, obj.cost}, @obj.contract_cost
    end

    should_eventually "determine cost" do
      assert_equal (@obj.labor_cost + @obj.material_cost + @obj.contract_cost), @obj.cost
    end

    should "determine invoiced" do
      # excludes retainage
      assert_equal 5, @obj.labor_invoiced
      assert_equal 50, @obj.material_invoiced
      assert_equal 500, @obj.contract_invoiced
      assert_equal 555, @obj.invoiced
    end

    should "determine retainage" do
      # excludes retainage
      assert_equal 2, @obj.labor_retainage
      assert_equal 20, @obj.material_retainage
      assert_equal 200, @obj.contract_retainage
      assert_equal 222, @obj.retainage
    end
        
    should "determine paid" do
      assert_equal 1, @obj.labor_paid
      assert_equal 10, @obj.material_paid
      assert_equal 100, @obj.contract_paid
      assert_equal 111, @obj.paid 
    end

    should "determine retainage" do
      assert_equal 1, @obj.labor_retained
      assert_equal 10, @obj.material_retained
      assert_equal 100, @obj.contract_retained
      assert_equal 111, @obj.retained
    end
  end
end
