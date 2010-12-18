require File.dirname(__FILE__) + '/../test_helper'

#NOTE:  add retained to factory calls

class PaymentTest < ActiveSupport::TestCase
  context "An Payment" do
    setup do  
      @project = Factory :project
      @component = Factory :component, :project => @project
      @fc = Factory :fixed_cost_estimate, :component => @component, :raw_cost => 100
      
      @obj = Factory :payment, :project => @project, :date => Date::today, :paid => 90, :retained => 100
      
      @line1 = Factory( :payment_line, 
        :payment => @obj, 
        :cost => @fc,
        :labor_paid => 1,
        :material_paid => 10,
        :labor_retained => 100,
        :material_retained => 1000
      )
        
      @line2 = Factory( :payment_line, 
        :payment => @obj, 
        :cost => @fc,
        :labor_paid => 10000,
        :material_paid => 100000,
        :labor_retained => 1000000,
        :material_retained => 10000000
      )
      
      [@project, @component, @fc, @obj, @line1, @line2].each {|i| i.reload}
    end
    
    should "be valid" do
      assert @obj.valid?
    end
    
    should "have values" do
      assert_not_nil @obj.paid
      assert_not_nil @obj.date
      assert_not_nil @obj.state
    end
    
    should "require a project" do
      assert_raise ActiveRecord::RecordInvalid do
        Factory :payment, :project => nil
      end
    end
    
    should "have multiple line items" do
      assert_contains @obj.lines, @line1
      assert_contains @obj.lines, @line2
    end
    
    should "aggregate labor paid" do
      assert_equal 10001, @obj.labor_paid
    end
    
    should "aggregate material paid" do
      assert_equal 100010, @obj.material_paid
    end
    
    should "aggregate labor retained" do
      assert_equal 1000100, @obj.labor_retained
    end
    
    should "aggregate material retained" do
      assert_equal 10001000, @obj.material_retained
    end
    
    should_eventually "determine payment balanced" do
    end
    
    should_eventually "determine payment unbalanced" do
    end
  end
  

  context "state machine validation" do
    setup do
      @project = Factory :project
      @component = Factory :component, :project => @project
    end
  
    should "new -> missing_task if tasks have costs without estimates" do
      @task = Factory :task, :project => @project
      @mc = Factory :material_cost, :task => @task, :raw_cost => 100
      @obj = Factory :payment, :project => @project
      @obj.update_attributes :date => Date::today, :paid => 100, :retained => 100
      
      assert_equal 'missing_task', @obj.state
      assert_equal [], @obj.lines
    end
   
    should "missing_task -> unbalanced after task assigned" do
      @task = Factory :task, :project => @project
      @mc = Factory :material_cost, :task => @task, :raw_cost => 100
      @obj = Factory :payment, :project => @project
      @obj.update_attributes :date => Date::today, :paid => 100, :retained => 100
      
      assert_equal 'missing_task', @obj.state
      
      @fc = Factory :fixed_cost_estimate, :component => @component, :task => @task

      assert_equal false, @obj.reload.missing_tasks?
      
      assert_equal 'unbalanced', @obj.reload.state
    end
  end

  context "state machine" do
    setup do
      @project = Factory :project, :labor_percent_retainage => 10, :material_percent_retainage => 20
      @component = Factory :component, :project => @project
      @task = Factory :task, :project => @project
      @fc = Factory :fixed_cost_estimate, :component => @component, :raw_cost => 1, :task => @task
      @q = Factory :quantity, :component => @component, :value => 1
      @uc = Factory :unit_cost_estimate, :component => @component, :unit_cost => 10, :task => @task
      @c = Factory :contract, :component => @component, :project => @project
      @c.active_bid = Factory :bid, :raw_cost => 100, :contract => @c
      
      @l = Factory :laborer, :bill_rate => 1
      @lc = Factory :labor_cost, :task => @task
      @lcl = Factory :labor_cost_line, :labor_set => @lc, :laborer => @l, :hours => 10
      @mc = Factory :material_cost, :task => @task, :raw_cost => 100
      @cc = Factory :contract_cost, :contract => @c, :raw_cost => 1000
      
      @obj = Factory :payment, :project => @project, :date => nil, :paid => nil, :retained => nil
      
      [@project, @component, @task, @fc, @q, @uc, @c, @l, @lc, @lcl, @mc, @cc].each {|i| i.reload}
    end

    should "start as new" do
      assert_equal 'new', @obj.state
    end
    
    should "not new -> balanced if date not specified" do
      @obj.update_attributes :date => nil, :paid => 100, :retained => 100
      
      assert_equal 'new', @obj.reload.state
    end

    should "not new -> balanced if paid not specified" do
      @obj.update_attributes :date => Date::today, :paid => nil, :retained => 100
      
      assert_equal 'new', @obj.reload.state
    end

    should "not new -> balanced if retained not specified" do
      @obj.update_attributes :date => Date::today, :paid => nil, :retained => nil
      
      assert_equal 'new', @obj.reload.state
    end
           
    should "populate line items when -> balanced" do
      @obj.update_attributes :date => Date::today, :paid => 0, :retained => 0
      assert_equal 'balanced', @obj.reload.state
      
      costs = @obj.lines.map{|l| l.cost}
      assert_contains costs, @fc
      assert_contains costs, @uc
      assert_contains costs, @c
      
      assert_equal 3, @obj.reload.lines.count
    end

    should "populate line items when -> unbalanced" do
      @obj.update_attributes :date => Date::today, :paid => 100, :retained => 100
      assert_equal 'unbalanced', @obj.reload.state
      
      costs = @obj.lines.map{|l| l.cost}
      assert_contains costs, @fc
      assert_contains costs, @uc
      assert_contains costs, @c
      
      assert_equal 3, @obj.reload.lines.count
    end
    
    should "new -> balanced" do
      @obj.update_attributes :date => Date::today, :paid => 0, :retained => 0

      assert_equal 'balanced', @obj.reload.state
    end

    should "new -> unbalanced" do
      @obj.update_attributes :date => Date::today, :paid => 100, :retained => 100

      assert_equal 'unbalanced', @obj.reload.state
    end
           
    should "balanced -> unbalanced if unbalanced" do
      @obj.update_attributes :date => Date::today, :paid => 0, :retained => 0
      
      assert_equal 'balanced', @obj.reload.state
      
      # screw them up
      @obj.lines.each {|l| l.update_attributes :labor_paid => 1000 }

      assert_equal 'unbalanced', @obj.reload.state
    end

    should "unbalanced -> balanced after balancing" do
      @obj.update_attributes :date => Date::today, :paid => 0, :retained => 0
      
      assert_equal 'balanced', @obj.reload.state
      
      # screw them up
      @obj.reload.lines.each {|l| l.update_attributes :labor_paid => 1230984}
      
      assert_equal 'unbalanced', @obj.reload.state
      
      # fix them 
      @obj.reload.lines.each {|l| l.update_attributes :labor_paid => 0, :labor_retained => 0, :material_paid => 0, :material_retained => 0 }
      
      assert_equal 'balanced', @obj.reload.state
    end
    
    should "balanced -> complete" do
      @obj.update_attributes :date => Date::today, :paid => 0, :retained => 0

      @obj.accept_payment
      
      assert_equal 'complete', @obj.reload.state
    end

    should "not unbalanced -> complete" do
      @obj.update_attributes :date => Date::today, :paid => 900, :retained => 900
      
      @obj.reload.lines.each {|l| l.update_attributes :labor_paid => 1230984}
      @obj.accept_payment
      
      assert_equal 'unbalanced', @obj.reload.state
    end
  end
end
