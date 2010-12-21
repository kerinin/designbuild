require File.dirname(__FILE__) + '/../test_helper'

class InvoiceTest < ActiveSupport::TestCase
 
  context "An Invoice" do
    setup do
      @project = Factory :project
      @component = Factory :component, :project => @project
      @fc = Factory :fixed_cost_estimate, :component => @component, :raw_cost => 100
      @uc = Factory :unit_cost_estimate, :component => @component, :raw_cost => 0
      @c = Factory :contract, :component => @component
      
      @obj = Factory :invoice, :project => @project
      @obj.update_attributes :date => Date::today
      @obj.lines = []
      @obj.save!
      
      @line1 = @obj.lines.create( 
        #:invoice => @obj, 
        :cost => @fc,
        :labor_invoiced => 1,
        :material_invoiced => 10,
        :labor_retainage => 100,
        :material_retainage => 1000
      )
        
      @line2 = @obj.lines.create(
        #:invoice => @obj, 
        :cost => @fc,
        :labor_invoiced => 10000,
        :material_invoiced => 100000,
        :labor_retainage => 1000000,
        :material_retainage => 10000000
      )
      @obj.save!

      # This is interesting - the second puts shows the correct value, but once it's saved it gets lost
      puts @obj.lines.map{|l| l.labor_invoiced}
      @obj.lines_attributes = [{:id => @line1.id, :labor_invoiced => 5, :material_invoiced => 5, :labor_retainage => 5, :material_retainage => 5}]
      puts @obj.lines.map{|l| l.labor_invoiced}
      @obj.save!
      puts @obj.lines.map{|l| l.labor_invoiced}
      
      [@project, @component, @fc, @uc, @c, @obj, @line1, @line2].each {|i| i.reload}
    end

    should "accept_nested_attributes" do
      #assert_equal 'retainage_unexpected', @obj.state
      
      assert_equal 2, @obj.lines.count
      assert_contains @obj.lines, @line1
      
      puts 'start'
      @obj.update_attributes :lines_attributes => [{:id => @line1.id, :labor_invoiced => 5, :material_invoiced => 5, :labor_retainage => 5, :material_retainage => 5}]
      puts 'save'
      #@obj.save!
      puts 'end'
      
      puts @line1.reload.labor_invoiced
      
      assert_equal 2, @obj.lines.count
      assert_contains @obj.lines.map{|l| l.labor_invoiced}, 5
      assert_equal @line1, @obj.reload.lines.first
      
      assert_equal 5, @obj.lines[0].labor_invoiced
      assert_equal 5, @obj.lines[0].material_invoiced
      assert_equal 5, @obj.lines[0].labor_retainage
      assert_equal 5, @obj.lines[0].material_retainage
      
      assert_equal 5, @line1.reload.labor_invoiced
      assert_equal 5, @line1.reload.material_invoiced
      assert_equal 5, @line1.reload.labor_retainage
      assert_equal 5, @line1.reload.material_retainage
    end
=begin    
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
      assert_equal 10001, @obj.labor_invoiced
    end
    
    should "aggregate material invoiced" do
      assert_equal 100010, @obj.material_invoiced
    end
    
    should "aggregate invoiced" do
      assert_equal 110011, @obj.invoiced
    end
    
    should "aggregate labor retainage" do
      assert_equal 1000100, @obj.labor_retainage
    end
    
    should "aggregate material retainage" do
      assert_equal 10001000, @obj.material_retainage
    end
    
    should "aggregate retainage" do
      assert_equal 11001100, @obj.retainage
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

      assert_equal 'retainage_expected', @obj.reload.state
    end
   
    should "new -> payments_unbalanced if unbalanced payments" do
      @task = Factory :task, :project => @project
      @fc = Factory :fixed_cost_estimate, :component => @component, :task => @task
      @mc = Factory :material_cost, :task => @task, :raw_cost => 100
      
      @payment = Factory :payment, :project => @project, :date => Date::today-10, :paid => 100, :retained => 100
      
      @obj = Factory :invoice, :project => @project
      @obj.update_attributes :date => Date::today
      
      assert_equal false, @obj.reload.missing_tasks?
      assert_equal true, @obj.reload.unbalanced_payments?
      
      assert_equal 'payments_unbalanced', @obj.state
    end
  
    should "payments_unbalanced -> retainage_expected after payments balanced" do
      @task = Factory :task, :project => @project
      @fc = Factory :fixed_cost_estimate, :component => @component, :task => @task
      @mc = Factory :material_cost, :task => @task, :raw_cost => 100
      
      @payment = Factory :payment, :project => @project, :date => Date::today-10, :paid => 100, :retained => 100
      
      @obj = Factory :invoice, :project => @project
      @obj.update_attributes :date => Date::today
      
      #[@project, @component, @payment, @task, @fc, @mc, @obj].each {|i| i.reload}
      #assert_equal false, @payment.balances?
      #assert_contains @obj.project.payments, @payment
      #assert @project.payments.map{|p| p.balances?}.include?( false )
      #assert_equal false, @project.payments.empty?
      #assert_equal true, @obj.unbalanced_payments?
      
      assert_equal 'payments_unbalanced', @obj.reload.state    
    
      @payment.lines = [
        Factory( :payment_line,
        :payment => @payment,
        :cost => @fc,
        :labor_paid => 90,
        :material_paid => 10,
        :labor_retained => 90,
        :material_retained => 10
      ) ]
      #@payment.save
      
      assert @payment.balances?
      assert_equal 1, @obj.project.payments.count
      assert_contains @obj.project.payments, @payment
      assert_equal 1, @payment.lines.count
      assert_equal false, @obj.unbalanced_payments?
      assert_contains @payment.project.reload.invoices, @obj
      #@obj.save
      #@payment.project.reload.invoices.each {|i| i.save!}
      #@payment.update_invoices
      #@payment.save
      #@payment.lines.first.save
      
      #@payment.save
      # NOTE: explicitly saving passes
      # invoice.save being called after line added (see puts)
      # Not sure why this isn't working
      
      assert_equal 'retainage_expected', @obj.reload.state
    end
     
    should "new -> missing_task if tasks missing and payments unbalanced" do
      @task = Factory :task, :project => @project
      @fc = Factory :fixed_cost_estimate, :component => @component
      @mc = Factory :material_cost, :task => @task, :raw_cost => 100
      @payment = Factory :payment, :project => @project, :date => Date::today-10, :paid => 100, :retained => 100
      
      @obj = Factory :invoice, :project => @project
      @obj.update_attributes :date => Date::today
      
      assert_equal 'missing_task', @obj.state
    end
    
    should "missing_task -> payments_unbalanced after task assigned if payments unbalanced" do
      @task = Factory :task, :project => @project
      @fc = Factory :fixed_cost_estimate, :component => @component
      @mc = Factory :material_cost, :task => @task, :raw_cost => 100
      @payment = Factory :payment, :project => @project, :date => Date::today-10, :paid => 100, :retained => 100
      
      @obj = Factory :invoice, :project => @project
      @obj.update_attributes :date => Date::today
      
      assert_equal 'missing_task', @obj.reload.state
      
      @fc.task = @task
      @fc.save
      
      assert_equal 'payments_unbalanced', @obj.reload.state
      
      @payment.lines = [
        Factory( :payment_line,
        :payment => @payment,
        :cost => @fc,
        :labor_paid => 90,
        :material_paid => 10,
        :labor_retained => 90,
        :material_retained => 10
      ) ]
      
      assert_equal 'retainage_expected', @obj.reload.state
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
   
    should "populate line items when -> retainage_expected" do
      @obj.update_attributes :date => Date::today
      
      costs = @obj.lines.map{|l| l.cost}
      assert_contains costs, @fc
      assert_contains costs, @uc
      assert_contains costs, @c
      
      assert_equal 3, @obj.reload.lines.count
    end

    should "new -> retainage expected if retainage specified" do
      @obj.update_attributes :date => Date::today
      
      # auto-generates with correct retainage

      assert_equal 'retainage_expected', @obj.reload.state
    end
       
    should "retainage expected -> retainage unexpected if unexpected" do
      @obj.update_attributes :date => Date::today
      
      # auto-generates with correct retainage
      assert_equal 'retainage_expected', @obj.reload.state
      
      # screw them up
      @obj.lines.each {|l| l.update_attributes :labor_retainage => 1000, :material_retainage => 1000 }

      assert_equal 'retainage_unexpected', @obj.reload.state
    end

    should "retainage unexpected -> retainage expected if expected" do
      @obj.update_attributes :date => Date::today
      
      # auto-generates with correct retainage
      assert_equal 'retainage_expected', @obj.reload.state
      
      # screw them up
      @obj.reload.lines.each {|l| l.update_attributes :labor_retainage => 1230984, :material_retainage => 985328374}
      
      assert_equal 'retainage_unexpected', @obj.reload.state
      
      # fix them 
      @obj.reload.lines.each {|l| l.update_attributes :labor_invoiced => 9, :labor_retainage => 1, :material_invoiced => 8, :material_retainage => 2 }
      
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
=end
  end
end
