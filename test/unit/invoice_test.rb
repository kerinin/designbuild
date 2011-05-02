require File.dirname(__FILE__) + '/../test_helper'

class InvoiceTest < ActiveSupport::TestCase
  context "An Invoice" do
    setup do
      @q = Factory :quantity, :value => 1
      @project = Factory :project
      @component = @project.components.create! :name => 'component'
      @markup = Factory :markup, :percent => 50
      @component.markups << @markup
      @fc = @component.fixed_cost_estimates.create! :name => 'fixed cost', :raw_cost => 100
      @uc = @component.unit_cost_estimates.create! :name => 'unit cost', :quantity => @q, :unit_cost => 0
      @c = @component.contracts.create! :name => 'contract'
    
      @obj = @project.invoices.create! :date => Date::today
      @obj.lines = []
      @obj.save!
    
      @line1 = @obj.lines.create!( :component => @component )
      @line1.update_attributes(
        :labor_invoiced => 1,
        :material_invoiced => 10,
        :labor_retainage => 100,
        :material_retainage => 1000
      )
      
      @line2 = @obj.lines.create!( :component => @component )
      @line2.update_attributes(
        :labor_invoiced => 10000,
        :material_invoiced => 100000,
        :labor_retainage => 1000000,
        :material_retainage => 10000000
      )
      
      @markup_line = @obj.markup_lines.create!(:markup => @markup)
      #@obj.advance
    end  

    should "accept_nested_attributes" do
      @obj.update_attributes :lines_attributes => [{:id => @line1.id, :labor_invoiced => 5, :material_invoiced => 5, :labor_retainage => 5, :material_retainage => 5}]

      @line1.reload
    
      assert_equal 5, @line1.labor_invoiced
      assert_equal 5, @line1.material_invoiced
      assert_equal 5, @line1.labor_retainage
      assert_equal 5, @line1.material_retainage
    end
   
    should "be valid" do
      assert @obj.valid?
    end
  
    should "have values" do
      assert_not_nil @obj.date
      assert_not_nil @obj.state
    end
  
    should "require a project" do
      assert_raise ActiveRecord::RecordInvalid do
        Factory :invoice, :project => nil
      end
    end
  
    should "allow a template" do
      @i = Factory :invoice, :template => 'blah'
      assert_equal 'blah', @i.template
    end
  
    should "have multiple line items" do
      assert_contains @obj.lines, @line1
      assert_contains @obj.lines, @line2
    end

    should "aggregate labor invoiced" do
      assert_equal 15001.5, @obj.labor_invoiced
    end

    should "aggregate material invoiced" do
      assert_equal 150015, @obj.material_invoiced
    end
  
    should "aggregate invoiced" do
      assert_equal 165016.5, @obj.invoiced
    end
  
    should "aggregate labor retainage" do
      assert_equal 1500150, @obj.labor_retainage
    end
  
    should "aggregate material retainage" do
      assert_equal 15001500, @obj.material_retainage
    end
  
    should "aggregate retainage" do
      assert_equal 16501650, @obj.retainage
    end
  end

  context "state machine validation" do
    setup do
      @project = Factory :project
      @component = @project.components.create! :name => 'component'
    end

    should "new -> unassigned_costs if costs exist without component" do
      @task = @project.tasks.create! :name => 'task'
      @mc = @task.material_costs.create! :raw_cost => 100, :supplier => Factory(:supplier), :date => Date::today
      @obj = @project.invoices.create! :date => Date::today

      @obj.advance
    
      assert_nil @mc.component
    
      assert_equal 'unassigned_costs', @obj.state
      assert_equal [], @obj.lines
    end

    should "unassigned_costs -> retainage_expected after cost assigned to component" do
      @task = @project.tasks.create! :name => 'task'
      @mc = @task.material_costs.create! :raw_cost => 100, :supplier => Factory(:supplier), :date => Date::today
      @obj = @project.invoices.create! :date => Date::today
      @obj.advance
    
      assert_equal 'unassigned_costs', @obj.state
    
      @mc.update_attributes(:component_id => @component.id)
      @obj.advance

      assert_equal 'retainage_expected', @obj.state
    end

    should "new -> payments_unbalanced if unbalanced payments" do
      @task = @project.tasks.create! :name => 'task'
      @fc = @component.fixed_cost_estimates.create! :name => 'fixed cost', :raw_cost => 100
      @task.fixed_cost_estimates << @fc
      @mc = @task.material_costs.create! :raw_cost => 100, :supplier => Factory(:supplier), :date => Date::today
    
      @payment = @project.payments.create! :date => Date::today-10, :paid => 100, :retained => 100
    
      @obj = @project.invoices.create! :date => Date::today
      @obj.advance
    
      assert_equal false, @obj.unassigned_costs?
      assert_equal true, @obj.unbalanced_payments?
    
      assert_equal 'payments_unbalanced', @obj.state
    end

    should "payments_unbalanced -> retainage_expected after payments balanced" do
      @task = @project.tasks.create! :name => 'task'
      @fc = @component.fixed_cost_estimates.create! :name => 'fixed cost', :raw_cost => 100
      @task.fixed_cost_estimates << @fc
      @mc = @task.material_costs.create! :raw_cost => 100, :supplier => Factory(:supplier), :date => Date::today
    
      @payment = @project.payments.create! :date => Date::today-10, :paid => 100, :retained => 100
    
      @obj = @project.invoices.create! :date => Date::today
      @obj.advance!
    
      assert_equal 'payments_unbalanced', @obj.state    
  
      @payment.lines = [
        Factory( :payment_line,
        :payment => @payment,
        :component => @component,
        :labor_paid => 90,
        :material_paid => 10,
        :labor_retained => 90,
        :material_retained => 10
      ) ]
      @obj.advance!

      assert_equal 'retainage_expected', @obj.state
    end
 
    should "new -> unassigned_costs if costs exist w/o component and payments unbalanced" do
      @task = @project.tasks.create! :name => 'task'
      @fc = @component.fixed_cost_estimates.create! :name => 'fixed cost', :raw_cost => 100
      @mc = @task.material_costs.create! :raw_cost => 100, :supplier => Factory(:supplier), :date => Date::today
      @payment = @project.payments.create! :date => Date::today-10, :paid => 100, :retained => 100
    
      @obj = @project.invoices.create! :date => Date::today
      @obj.advance
    
      assert_equal 'unassigned_costs', @obj.state
    end
  
    should "unassigned_costs -> payments_unbalanced after cost assigned if payments unbalanced" do
      @task = @project.tasks.create! :name => 'task'
      @fc = @component.fixed_cost_estimates.create! :name => 'fixed cost', :raw_cost => 100
      @mc = @task.material_costs.create! :raw_cost => 100, :supplier => Factory(:supplier), :date => Date::today
      @payment = @project.payments.create! :date => Date::today-10, :paid => 100, :retained => 100
    
      @obj = @project.invoices.create! :date => Date::today
      @obj.advance
    
      assert_equal 'unassigned_costs', @obj.state
    
      @mc.update_attributes(:component_id => @component.id)
      @fc.update_attributes(:component_id => @component.id)
      @obj.advance
    
      assert_equal 'payments_unbalanced', @obj.state
    
      @payment.lines = [
        Factory( :payment_line,
        :payment => @payment,
        :component => @component,
        :labor_paid => 90,
        :material_paid => 10,
        :labor_retained => 90,
        :material_retained => 10
      ) ]
      @obj.advance
    
      assert_equal 'retainage_expected', @obj.reload.state
    end
  end

  context "state machine" do
    setup do
      @project = Factory :project, :labor_percent_retainage => 10, :material_percent_retainage => 20
      @component = @project.components.create! :name => 'test component' 
      @task = @project.tasks.create! :name => 'test task'
      @fc = @component.fixed_cost_estimates.create! :name => 'test fc', :raw_cost => 1
      @task.fixed_cost_estimates << @fc
    
      @q = @component.quantities.create! :name => 'test quantity', :value => 1
      @uc = @component.unit_cost_estimates.create! :name => 'test uc', :unit_cost => 10, :quantity => @q
      @task.unit_cost_estimates << @uc
    
      @c = @project.contracts.create! :name => 'test contract', :component => @component
      @component.contracts << @c
    
      @c.update_attributes :active_bid => Factory( :bid, :raw_cost => 100, :contract => @c )
    
      @l = Factory :laborer, :bill_rate => 1
      @lc = @task.labor_costs.create! :date => Date::today, :percent_complete => 100
      @lcl = @lc.line_items.create! :laborer => @l, :hours => 10
      @mc = @task.material_costs.create! :date => Date::today, :raw_cost => 100, :supplier => Factory(:supplier)
      @cc = @c.costs.create! :date => Date::today, :raw_cost => 1000
    
      @obj = @project.invoices.create!
    end

    should "start as new" do
      assert_equal 'new', @obj.state
    end
  
    should "not -> date set if date not specified" do
      @obj.advance
    
      assert_equal 'new', @obj.state
    end
 
    should "populate line items when -> retainage_expected" do
      @obj.update_attributes :date => Date::today
      @obj.advance
    
      assert_equal 'retainage_expected', @obj.state
    
      assert_equal 1, @obj.lines.count
    end

    should "new -> retainage expected if retainage specified" do
      @obj.update_attributes :date => Date::today
      @obj.advance

      assert_equal 'retainage_expected', @obj.state
    end
  
    should "retainage expected -> retainage unexpected if unexpected" do
      @obj.update_attributes :date => Date::today
      @obj.advance
    
      assert_equal 'retainage_expected', @obj.state
    
      # screw them up
      @obj.lines.each do |l|
        l.update_attributes :labor_retainage => 5648976, :material_retainage => 21354 
      end

      @obj.advance

      assert_equal 'retainage_unexpected', @obj.state
    end

    should "retainage unexpected -> retainage expected if expected" do
      @obj.update_attributes :date => Date::today
      @obj.advance!
    
      assert_equal 'retainage_expected', @obj.state
    
      # screw them up
      @obj.lines.each {|l| l.update_attributes :labor_retainage => 1230984, :material_retainage => 985328374}
      @obj.advance!
    
      assert_equal 'retainage_unexpected', @obj.state

      @obj.lines.each {|l| l.update_attributes :labor_invoiced => 9, :labor_retainage => 1, :material_invoiced => 8, :material_retainage => 2 }
      @obj.advance!

      assert_equal 'retainage_expected', @obj.state
    end

    should "retainage unexpected -> costs_specified" do
      @obj.update_attributes :date => Date::today
    

      @obj.lines.each {|l| l.labor_retainage = 1000; l.material_retainage = 1000; l.save; }
      @obj.advance
      @obj.accept_costs
    
      assert_equal 'costs_specified', @obj.state
    end

    should "retainage expected -> costs_specified" do
      @obj.update_attributes :date => Date::today
    
      @obj.advance
      @obj.accept_costs
    
      assert_equal 'costs_specified', @obj.state
    end
    
    should "costs_specified -> markups_added" do
      @obj.update_attributes :date => Date::today
    
      @obj.advance
      @obj.accept_costs
    
      assert_equal 'costs_specified', @obj.state
      
      @obj.accept_markups
      assert_equal 'markups_added', @obj.state
    end
              
    should "markups_added -> complete if template specified" do
      @obj.update_attributes :date => Date::today
    
      @obj.advance
      @obj.accept_costs
      
      @obj.accept_markups
    
      @obj.update_attributes :template => 'blah'
      @obj.advance
    
      assert_equal 'complete', @obj.state
    end
  end
end