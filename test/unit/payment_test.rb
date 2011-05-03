require File.dirname(__FILE__) + '/../test_helper'

#NOTE:  add retained to factory calls

class PaymentTest < ActiveSupport::TestCase

  context "A Payment" do
    setup do  
      @project = Factory :project
      @component = @project.components.create! :name => 'component'
      @markup = Factory :markup, :percent => 50
      @component.markups << @markup
      @fc = @component.fixed_cost_estimates.create! :name => 'fixed cost', :raw_cost => 100
      
      @obj = @project.payments.create! :date => Date::today, :paid => 90, :retained => 100
      
      @line1 = @obj.lines.create!(
        :component => @component,
        :labor_paid => 1,
        :material_paid => 10,
        :labor_retained => 100,
        :material_retained => 1000
      )
        
      @line2 = @obj.lines.create!(
        :component => @component,
        :labor_paid => 10000,
        :material_paid => 100000,
        :labor_retained => 1000000,
        :material_retained => 10000000
      )
      
      @markup_line = @obj.markup_lines.create!(:markup => @markup)
      @obj.advance!
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
    
    should "aggregate values" do
      assert_equal 15001.5, @obj.labor_paid
      assert_equal 150015, @obj.material_paid
      assert_equal 1500150, @obj.labor_retained
      assert_equal 15001500, @obj.material_retained
    end
    
    should "determine payment balanced/unbalanced" do
      assert_equal false, @obj.paid_balances?
      assert_equal false, @obj.retained_balances?
      assert_equal false, @obj.balances?
      
      @obj.update_attributes :paid => 15001.5 + 150015, :retained => 1500150 + 15001500
      
      assert_equal true, @obj.paid_balances?
      assert_equal true, @obj.retained_balances?
      assert_equal true, @obj.balances?
    end
  end
  
  context "state machine validation" do
    setup do
      @project = Factory :project
      @component = @project.components.create! :name => 'component'
    end
  
    should "new -> unassigned_costs if costs exist without components" do
      @task = @project.tasks.create! :name => 'task'
      @mc = @task.material_costs.create! :date => Date::today, :raw_cost => 100, :supplier => Factory(:supplier)
      @obj = @project.payments.create! :date => Date::today, :paid => 100, :retained => 100
      @obj.advance!
      
      assert_equal 'unassigned_costs', @obj.state
      assert_equal [], @obj.lines
    end
   
    should "unassigned_costs -> unbalanced after costs assigned to component" do
      @task = @project.tasks.create! :name => 'task'
      @mc = @task.material_costs.create! :date => Date::today, :raw_cost => 100, :supplier => Factory(:supplier)
      @obj = @project.payments.create! :date => Date::today, :paid => 100, :retained => 100
      @obj.advance!
      
      assert_equal 'unassigned_costs', @obj.state
      
      @mc.update_attributes(:component_id => @component.id)
      @obj.advance!

      assert_equal false, @obj.unassigned_costs?
      assert_equal false, @obj.balances?
      
      assert_equal 'unbalanced', @obj.state
    end
  end

  context "state machine" do
    setup do
      @project = Factory :project, :labor_percent_retainage => 10, :material_percent_retainage => 20
      @component = @project.components.create! :name => 'component'
      @task = @project.tasks.create! :name => 'task'
      @fc = @component.fixed_cost_estimates.create! :name => 'fixed cost', :raw_cost => 1
      @task.fixed_cost_estimates << @fc
      @q = Factory :quantity, :component => @component, :value => 1
      @uc = @component.unit_cost_estimates.create! :name => 'unit cost', :unit_cost => 10, :quantity => @q
      @task.unit_cost_estimates << @uc
      @c = @project.contracts.create! :name => 'contract', :component => @component
      @component.contracts << @c
      @c.update_attributes :active_bid => @c.bids.create!( :contractor => 'contractor', :raw_cost => 100, :date => Date::today )
      
      @l = Factory :laborer, :bill_rate => 1
      @lc = @task.labor_costs.create! :date => Date::today, :percent_complete => 50
      @lcl = @lc.line_items.create! :laborer => @l, :hours => 10
      @mc = @task.material_costs.create! :date => Date::today, :raw_cost => 100, :supplier => Factory(:supplier)
      @cc = @c.costs.create! :raw_cost => 1000, :date => Date::today
      
      @obj = @project.payments.create!
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
      
      assert_equal 1, @obj.lines.count
    end

    should "populate line items when -> unbalanced" do
      @obj.update_attributes :date => Date::today, :paid => 100, :retained => 100
      @obj.advance!
      
      assert_equal 'unbalanced', @obj.state
      
      assert_equal 1, @obj.lines.count
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
