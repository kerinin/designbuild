require File.dirname(__FILE__) + '/../test_helper'

class InvoiceTest < ActiveSupport::TestCase
=begin
  context "An Invoice" do
    setup do
      @project = Factory :project, :name => '1'
      @project.update_attributes(:name => '2')
      @project.update_attributes(:name => '3')
      @project.update_attributes(:name => '4')
      
      @obj = Factory :invoice, :project => @project
      
      @line1 = Factory :invoice_line, :invoice => @obj
      @line2 = Factory :invoice_line, :invoice => @obj
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
  end
=end
  context "state machine validation" do
    setup do
      @project = Factory :project
      @component = Factory :component, :project => @project
    end
  
    should "new -> missing_task if tasks have costs without estimates" do
      @task = Factory :task, :project => @project
      @mc = Factory :material_cost, :task => @task, :raw_cost => 100
      @obj = Factory :invoice, :project => @project
      @obj.update_attributes :date => Date::today
      
      assert_equal 'missing_task', @obj.state
      assert_equal [], @obj.lines
    end
    
    should "missing_task -> retainage_expected after task assigned" do
      @task = Factory :task, :project => @project
      @mc = Factory :material_cost, :task => @task, :raw_cost => 100
      @obj = Factory :invoice, :project => @project
      @obj.update_attributes :date => Date::today
      
      assert_equal 'missing_task', @obj.state
      
      @fc = Factory :fixed_cost_estimate, :component => @component, :task => @task
      
      assert_equal 'retainage_expected', @obj.state
    end
    
    should "new -> payments_unbalanced if unbalanced payments" do
      @task = Factory :task, :project => @project
      @fc = Factory :fixed_cost_estimate, :component => @component, :task => @task
      @mc = Factory :material_cost, :task => @task, :raw_cost => 100
      
      @payment = Factory :payment, :project => @project, :date => Date::today-10, :paid => 100
      
      @obj = Factory :invoice
      @obj.update_attributes :date => Date::today
      
      assert_equal 'payments_unbalanced', @obj.state
    end
    
    should "payments_unbalanced -> retainage_expected after payments balanced" do
      @task = Factory :task, :project => @project
      @fc = Factory :fixed_cost_estimate, :component => @component, :task => @task
      @mc = Factory :material_cost, :task => @task, :raw_cost => 100
      
      @payment = Factory :payment, :project => @project, :date => Date::today-10, :paid => 100
      
      @obj = Factory :invoice
      @obj.update_attributes :date => Date::today
      
      assert_equal 'payments_unbalanced', @obj.state    
    
       @payment.lines = [
        Factory( :payment_line,
        :payment => @payment,
        :cost => @fc,
        :labor_paid => 45,
        :material_paid => 5,
        :labor_retained => 45,
        :material_retained => 5
      ) ]
      
      assert_equal 'retainage_expected', @obj.state
    end
    
    should "new -> missing_task if tasks missing and payments unbalanced" do
      @task = Factory :task, :project => @project
      @fc = Factory :fixed_cost_estimate, :component => @component
      @mc = Factory :material_cost, :task => @task, :raw_cost => 100
      @payment = Factory :payment, :project => @project, :date => Date::today-10, :paid => 100
      
      @obj = Factory :invoice, :project => @project
      @obj.update_attributes :date => Date::today
      
      assert_equal 'missing_task', @obj.state
      
      @fc.task = @task
      
      assert_equal 'payments_unbalanced', @obj.state
    end
    
    should "missing_task -> payments_unbalanced after task assigned if payments unbalanced" do
      @task = Factory :task, :project => @project
      @fc = Factory :fixed_cost_estimate, :component => @component
      @mc = Factory :material_cost, :task => @task, :raw_cost => 100
      @payment = Factory :payment, :project => @project, :date => Date::today-10, :paid => 100
      
      @obj = Factory :invoice, :project => @project
      @obj.update_attributes :date => Date::today
      
      assert_equal 'missing_task', @obj.state
      
      @fc.task = @task
      
      assert_equal 'payments_unbalanced', @obj.state
      
      @payment.lines = [
        Factory( :payment_line,
        :payment => @payment,
        :cost => @fc,
        :labor_paid => 45,
        :material_paid => 5,
        :labor_retained => 45,
        :material_retained => 5
      ) ]
      
      assert_equal 'retainage_expected', @obj.state
    end
  end
=begin  
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
      
      @obj = Factory :invoice, :project => @project, :state => 'new', :date => nil
      
      [@project, @component, @task, @fc, @q, @uc, @c, @l, @lc, @lcl, @mc, @cc].each {|i| i.reload}
    end

    should "start as new" do
      assert_equal 'new', @obj.state
    end
    
    should "not -> date set if date not specified" do
      @obj.advance
      
      assert_equal 'new', @obj.reload.state
    end
   
    should "populate line items when -> date_specified" do
      @obj.update_attributes :date => Date::today
      
      costs = @obj.lines.map{|l| l.cost}
      assert_contains costs, @fc
      assert_contains costs, @uc
      assert_contains costs, @c
      
      assert_equal 3, @obj.reload.lines.count
    end
   
    should "-> retainage unexpected if unexpected" do
      @obj.update_attributes :date => Date::today
      
      # auto-generates with correct retainage
      
      # screw them up
      @obj.lines.each {|l| l.labor_retainage = 1000; l.material_retainage = 1000; l.save; }
      @obj.advance

      assert_equal 'retainage_unexpected', @obj.reload.state
    end

    should "-> retainage expected if retainage specified" do
      @obj.update_attributes :date => Date::today
      
      # auto-generates with correct retainage

      # finishes
      @obj.advance

      assert_equal 'retainage_expected', @obj.reload.state
    end

    should "retainage unexpected -> costs_specified" do
      @obj.update_attributes :date => Date::today
      

      @obj.lines.each {|l| l.labor_retainage = 1000; l.material_retainage = 1000; l.save; }
      @obj.advance
      @obj.accept_costs
      
      assert_equal 'costs_specified', @obj.reload.state
    end

    should "retainage expected -> costs_specified" do
      @obj.update_attributes :date => Date::today
      
      @obj.advance
      @obj.accept_costs
      
      assert_equal 'costs_specified', @obj.reload.state
    end
              
    should "costs_specified -> complete if template specified" do
      @obj.update_attributes :date => Date::today
      
      @obj.advance
      @obj.accept_costs
      
      @obj.update_attributes :template => 'blah'
      
      assert_equal 'complete', @obj.reload.state
    end
  end
=end
end
