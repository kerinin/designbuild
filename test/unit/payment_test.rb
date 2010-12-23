require File.dirname(__FILE__) + '/../test_helper'

#NOTE:  add retained to factory calls

class PaymentTest < ActiveSupport::TestCase
  context "A Payment" do
    setup do  
      @project = Factory :project
      #@component = Factory :component, :project => @project
      @component = @project.components.create! :name => 'component'
      #@fc = Factory :fixed_cost_estimate, :component => @component, :raw_cost => 100
      @fc = @component.fixed_cost_estimates.create! :name => 'fixed cost', :raw_cost => 100
      
      #@obj = Factory :payment, :project => @project, :date => Date::today, :paid => 90, :retained => 100
      @obj = @project.payments.create! :date => Date::today, :paid => 90, :retained => 100
      
      @line1 = @obj.lines.create!(
        :cost => @fc,
        :labor_paid => 1,
        :material_paid => 10,
        :labor_retained => 100,
        :material_retained => 1000
      )
        
      @line2 = @obj.lines.create!(
        :cost => @fc,
        :labor_paid => 10000,
        :material_paid => 100000,
        :labor_retained => 1000000,
        :material_retained => 10000000
      )
      
      #[@project, @component, @fc, @obj, @line1, @line2].each {|i| i.reload}
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
      #@component = Factory :component, :project => @project
      @component = @project.components.create! :name => 'component'
    end
  
    should "new -> missing_task if tasks have costs without estimates" do
      #@task = Factory :task, :project => @project
      @task = @project.tasks.create! :name => 'task'
      #@mc = Factory :material_cost, :task => @task, :raw_cost => 100
      @mc = @task.material_costs.create! :date => Date::today, :raw_cost => 100, :supplier => Factory(:supplier)
      #@obj = Factory :payment, :project => @project
      @obj = @project.payments.create! :date => Date::today, :paid => 100, :retained => 100
      @obj.advance!
      
      assert_equal 'missing_task', @obj.state
      assert_equal [], @obj.lines
    end
   
    should "missing_task -> unbalanced after task assigned" do
      #@task = Factory :task, :project => @project
      @task = @project.tasks.create! :name => 'task'
      #@mc = Factory :material_cost, :task => @task, :raw_cost => 100
      @mc = @task.material_costs.create! :date => Date::today, :raw_cost => 100, :supplier => Factory(:supplier)
      #@obj = Factory :payment, :project => @project
      @obj = @project.payments.create! :date => Date::today, :paid => 100, :retained => 100
      @obj.advance!
      
      assert_equal 'missing_task', @obj.state
      
      #@fc = Factory :fixed_cost_estimate, :component => @component, :task => @task
      @fc = @component.fixed_cost_estimates.create! :name => 'fixed cost', :raw_cost => 100
      @task.fixed_cost_estimates << @fc
      @obj.advance!

      assert_equal false, @obj.missing_tasks?
      assert_equal false, @obj.balances?
      
      assert_equal 'unbalanced', @obj.state
    end
  end

  context "state machine" do
    setup do
      @project = Factory :project, :labor_percent_retainage => 10, :material_percent_retainage => 20
      #@component = Factory :component, :project => @project
      @component = @project.components.create! :name => 'component'
      #@task = Factory :task, :project => @project
      @task = @project.tasks.create! :name => 'task'
      #@fc = Factory :fixed_cost_estimate, :component => @component, :raw_cost => 1, :task => @task
      @fc = @component.fixed_cost_estimates.create! :name => 'fixed cost', :raw_cost => 1
      @task.fixed_cost_estimates << @fc
      @q = Factory :quantity, :component => @component, :value => 1
      #@uc = Factory :unit_cost_estimate, :component => @component, :unit_cost => 10, :task => @task
      @uc = @component.unit_cost_estimates.create! :name => 'unit cost', :unit_cost => 10, :quantity => @q
      @task.unit_cost_estimates << @uc
      #@c = Factory :contract, :component => @component, :project => @project
      @c = @project.contracts.create! :name => 'contract'
      @component.contracts << @c
      @c.update_attributes :active_bid => @c.bids.create!( :contractor => 'contractor', :raw_cost => 100, :date => Date::today )
      
      @l = Factory :laborer, :bill_rate => 1
      #@lc = Factory :labor_cost, :task => @task
      @lc = @task.labor_costs.create! :date => Date::today, :percent_complete => 50
      #@lcl = Factory :labor_cost_line, :labor_set => @lc, :laborer => @l, :hours => 10
      @lcl = @lc.line_items.create! :laborer => @l, :hours => 10
      #@mc = Factory :material_cost, :task => @task, :raw_cost => 100
      @mc = @task.material_costs.create! :date => Date::today, :raw_cost => 100, :supplier => Factory(:supplier)
      #@cc = Factory :contract_cost, :contract => @c, :raw_cost => 1000
      @cc = @c.costs.create! :raw_cost => 1000, :date => Date::today
      
      #@obj = Factory :payment, :project => @project, :date => nil, :paid => nil, :retained => nil
      @obj = @project.payments.create!
      
      #[@project, @component, @task, @fc, @q, @uc, @c, @l, @lc, @lcl, @mc, @cc].each {|i| i.reload}
    end

    should "start as new" do
      assert_equal 'new', @obj.state
    end
    
    should "not new -> balanced if date not specified" do
      @obj.update_attributes :date => nil, :paid => 100, :retained => 100
      @obj.advance!
      
      assert_equal 'new', @obj.state
    end

    should "not new -> balanced if paid not specified" do
      @obj.update_attributes :date => Date::today, :paid => nil, :retained => 100
      @obj.advance!
      
      assert_equal 'new', @obj.state
    end

    should "not new -> balanced if retained not specified" do
      @obj.update_attributes :date => Date::today, :paid => nil, :retained => nil
      @obj.advance!
      
      assert_equal 'new', @obj.state
    end
           
    should "populate line items when -> balanced" do
      @obj.update_attributes :date => Date::today, :paid => 0, :retained => 0
      @obj.advance!
      assert_equal 'balanced', @obj.state
      
      costs = @obj.lines.map{|l| l.cost}
      assert_contains costs, @fc
      assert_contains costs, @uc
      assert_contains costs, @c
      
      @obj.advance!
      
      assert_equal 3, @obj.lines.count
    end

    should "populate line items when -> unbalanced" do
      @obj.update_attributes :date => Date::today, :paid => 100, :retained => 100
      @obj.advance!
      
      assert_equal 'unbalanced', @obj.state
      
      costs = @obj.lines.map{|l| l.cost}
      assert_contains costs, @fc
      assert_contains costs, @uc
      assert_contains costs, @c
      
      @obj.advance!
      
      assert_equal 3, @obj.lines.count
    end
    
    should "new -> balanced" do
      @obj.update_attributes :date => Date::today, :paid => 0, :retained => 0
      @obj.advance!
      
      assert_equal 'balanced', @obj.state
    end

    should "new -> unbalanced" do
      @obj.update_attributes :date => Date::today, :paid => 100, :retained => 100
      @obj.advance!

      assert_equal 'unbalanced', @obj.state
    end
           
    should "balanced -> unbalanced if unbalanced" do
      @obj.update_attributes :date => Date::today, :paid => 0, :retained => 0
      @obj.advance!
      
      assert_equal 'balanced', @obj.state
      
      # screw them up
      @obj.lines.each {|l| l.update_attributes :labor_paid => 1000 }
      @obj.advance!

      assert_equal 'unbalanced', @obj.state
    end

    should "unbalanced -> balanced after balancing" do
      @obj.update_attributes :date => Date::today, :paid => 0, :retained => 0
      @obj.advance!
      
      assert_equal 'balanced', @obj.state
      
      # screw them up
      @obj.lines(true).each {|l| l.update_attributes :labor_paid => 1230984}
      @obj.advance!
      
      #puts @obj.lines.count
      #puts @obj.labor_paid
      #assert_equal false, @obj.balances?
      assert_equal 'unbalanced', @obj.state
      
      # fix them 
      @obj.reload.lines.each {|l| l.update_attributes :labor_paid => 0, :labor_retained => 0, :material_paid => 0, :material_retained => 0 }
      @obj.advance!
      
      assert_equal 'balanced', @obj.state
    end
  
    should "balanced -> complete" do
      @obj.update_attributes :date => Date::today, :paid => 0, :retained => 0
      @obj.advance!
      @obj.accept_payment
      
      assert_equal 'complete', @obj.state
    end

    should "not unbalanced -> complete" do
      @obj.update_attributes :date => Date::today, :paid => 900, :retained => 900
      @obj.advance!
      
      @obj.lines.each {|l| l.update_attributes :labor_paid => 1230984}
      @obj.advance!
      @obj.accept_payment
      
      assert_equal 'unbalanced', @obj.state
    end
  end
  
end
