require File.dirname(__FILE__) + '/../test_helper'

class InvoiceableTest < ActiveSupport::TestCase
  context "Given a project" do
    setup do
      @project = Factory :project
      @component1 = Factory :component, :project => @project
      @task1 = Factory :task, :project => @project
      @component2 = Factory :component, :project => @project
      @task2 = Factory :task, :project => @project
      
      @l = Factory :laborer, :bill_rate => 1
      @lc = Factory :labor_cost, :task => @task1, :percent_complete => 50, :date => Date::today
      @lcl = Factory :labor_cost_line, :laborer => @l, :hours => 20, :labor_set => @lc
      @mc = Factory :material_cost, :task => @task1, :raw_cost => 30, :date => Date::today
      
      @lc2 = Factory :labor_cost, :task => @task1, :percent_complete => 50, :date => Date::today - 10
      @lcl2 = Factory :labor_cost_line, :laborer => @l, :hours => 20, :labor_set => @lc2
      @mc2 = Factory :material_cost, :task => @task1, :raw_cost => 30, :date => Date::today - 10
    end
    
    @fixed = Proc.new { |project, component1, task1, component2, task2, l, lc, lcl, mc|
      @fce1 = Factory :fixed_cost_estimate, :component => component1, :task => task1, :raw_cost => 1
      @fce2 = Factory :fixed_cost_estimate, :component => component1, :raw_cost => 10
      @fce3 = Factory :fixed_cost_estimate, :component => component2, :task => task2, :raw_cost => 100
      @fce4 = Factory :fixed_cost_estimate, :component => component1, :raw_cost => 1000
      
      [@fce1, @fce2, @fce3, @fce4].each {|i| i.reload}
      [@fce1, @fce2, @fce3, @fce4]
    }
    
    @unit = Proc.new { |project, component1, task1, component2, task2, l, lc, lcl, mc|
      @q = Factory :quantity, :component => component1, :value => 1
      @uce1 = Factory :unit_cost_estimate, :component => component1, :task => task1, :unit_cost => 2, :quantity => @q
      @uce2 = Factory :unit_cost_estimate, :component => component1, :unit_cost => 20, :quantity => @q
      @uce3 = Factory :unit_cost_estimate, :component => component2, :task => task2, :unit_cost => 200, :quantity => @q
      @uce4 = Factory :unit_cost_estimate, :component => component1, :unit_cost => 2000, :quantity => @q
      
      [@uce1, @uce2, @uce3, @uce4].each {|i| i.reload}
      [@uce1, @uce2, @uce3, @uce4]
    }
    
    @contract = Proc.new { |project, component1, task1, component2, task2, l, lc, lcl, mc|
      @contract1 = Factory :contract, :project => project, :component => component1, :active_bid => Factory( :bid, :raw_cost => 3 )
      @contract2 = Factory :contract, :project => project, :component => component2, :active_bid => Factory( :bid, :raw_cost => 30 )
      @contract3 = Factory :contract, :project => project, :active_bid => Factory( :bid, :raw_cost => 300 )

      Factory :contract_cost, :contract => @contract1, :raw_cost => 500, :date => Date::today
      Factory :contract_cost, :contract => @contract1, :raw_cost => 500, :date => Date::today - 10
      
      [@contract1, @contract2, @contract3].each {|i| i.reload}
      [@contract1, @contract2, @contract3]
    }
    # , [@unit, 'unit cost'], [@contract, 'contract']
    [[@fixed, 'fixed cost']].each do |proc, name|
      context "with #{name} invoices & payments" do
        setup do
          @targets = proc.call( @project, @component1, @task1, @component2, @task2, @l, @lc, @lcl, @lc2, @lcl2, @mc, @mc2)

          @invoice1 = Factory :invoice, :project => @project, :date => Date::today-10
          @invoice1.lines = @targets.map { |target|
            Factory( :invoice_line, 
            :invoice => @invoice1,
            :cost => target,
            :labor_invoiced => 4,
            :material_invoiced => 40,
            :labor_retainage => 400,
            :material_retainage => 4000
          ) }
          @invoice2 = Factory :invoice, :project => @project, :date => Date::today
          @invoice2.lines = @targets.map { |target|
            Factory( :invoice_line, 
            :invoice => @invoice2,
            :cost => target,
            :labor_invoiced => 4000,
            :material_invoiced => 40000,
            :labor_retainage => 400000,
            :material_retainage => 4000000
          ) }
                    
          @payment1 = Factory :payment, :project => @project, :date => Date::today-10
          @payment1.lines = @targets.map { |target|
            Factory( :payment_line,
            :payment => @payment1,
            :cost => target,
            :labor_paid => 5,
            :material_paid => 50,
            :labor_retained => 500,
            :material_retained => 5000
          ) }
          @payment2 = Factory :payment, :project => @project, :date => Date::today
          @payment2.lines = @targets.map { |target|
            Factory( :payment_line,
            :payment => @payment2,
            :cost => target,
            :labor_paid => 5000,
            :material_paid => 50000,
            :labor_retained => 500000,
            :material_retained => 5000000
          ) }
          
          [@project, @component1, @task1, @component2, @task2, @l, @lc, @lcl, @mc, @invoice1, @invoice2, @payment1, @payment2].each {|i| i.reload}
          @obj = @targets.first
        end
     
        teardown do
          Invoice.delete_all
          InvoiceLine.delete_all
        end
        
        should "aggregate labor_invoiced" do
          # This is all fucked up
          assert_equal 2, @obj.invoice_lines.count
          
          assert_equal 4004, @obj.labor_invoiced
        end
=begin        
        should "aggregate labor_invoiced with date cutoff" do
          assert_equal 4, @obj.labor_invoiced_before(Date::today - 5)
        end
     
        should "aggregate material_invoiced" do
          assert_equal 40040, @obj.material_invoiced
        end
        
        should "aggregate material invoice  with date cutoff" do
          assert_equal 40, @obj.material_invoiced_before(Date::today - 5)
        end
      
        should "aggregate invoiced" do
          assert_equal 44044, @obj.invoiced
        end
        
        should "aggregate invoiced  with date cutoff" do
          assert_equal 44, @obj.invoiced_before(Date::today - 5)
        end
  
        should "aggregate labor_retainage" do
          assert_equal 400400, @obj.labor_retainage
        end
        
        should "aggregate labor_retainage  with date cutoff" do
          assert_equal 400, @obj.labor_retainage_before(Date::today - 5)
        end
      
        should "aggregate material_retainage" do
          assert_equal 4004000, @obj.material_retainage
        end
        
        should "aggregate material_retainage  with date cutoff" do
          assert_equal 4000, @obj.material_retainage_before(Date::today - 5)
        end
      
        should "aggregate retainage" do
          assert_equal 4404400, @obj.retainage
        end
        
        should "aggregate retainage with date cutoff" do
          assert_equal 4400, @obj.retainage_before(Date::today - 5)
        end
      
        should "aggregate labor_paid" do
          assert_equal 5005, @obj.labor_paid
        end
        
        should "aggregate labor_paid with date cutoff" do
          assert_equal 5, @obj.labor_paid_before(Date::today - 5)
        end
      
        should "aggregate material_paid" do
          assert_equal 50050, @obj.material_paid
        end
        
        should "aggregate material_paid with date cutoff" do
          assert_equal 50, @obj.material_paid_before(Date::today - 5)
        end
      
        should "aggregate paid" do
          assert_equal 55055, @obj.paid
        end
        
        should "aggregate paid with date cutoff" do
          assert_equal 55, @obj.paid_before(Date::today - 5)
        end
      
        should "aggregate labor_retained" do
          assert_equal 500500, @obj.labor_retained
        end
        
        should "aggregate labor_retained with date cutoff" do
          assert_equal 500, @obj.labor_retained_before(Date::today - 5)
        end
      
        should "aggregate material_retained" do
          assert_equal 5005000, @obj.material_retained
        end
        
        should "aggregate material_retained with date cutoff" do
          assert_equal 5000, @obj.material_retained_before(Date::today - 5)
        end
      
        should "aggregate retained" do
          assert_equal 5505500, @obj.retained
        end
        
        should "aggregate retained with date cutoff" do
          assert_equal 5500, @obj.retained_before(Date::today - 5)
        end
      
        should "determine labor_percent" do
          assert_equal 40, @obj.labor_percent unless @obj.instance_of? Contract
          assert_equal 50, @obj.labor_percent if @obj.instance_of? Contract
        end
      
        should "determine material_percent" do
          assert_equal 60, @obj.material_percent unless @obj.instance_of? Contract
          assert_equal 50, @obj.material_percent if @obj.instance_of? Contract
        end
      
        should "determine labor outstanding" do
          assert_equal 4004-5005, @obj.labor_outstanding
        end
        
        should "determine labor outstanding with date cutoff" do
          assert_equal 4-5, @obj.labor_outstanding_before(Date::today - 5)
        end
      
        should "determine material_outstanding" do
          assert_equal 40040-50050, @obj.material_outstanding
        end
        
        should "determine material_outstanding with date cutoff" do
          assert_equal 40-50, @obj.material_outstanding_before(Date::today - 5)
        end
      
        should "determine outstanding" do
          assert_equal @obj.labor_outstanding + @obj.material_outstanding, @obj.outstanding
        end
        
        should "determine outstanding with date cutoff" do
          assert_equal @obj.labor_outstanding_before(Date::today - 5) + @obj.material_outstanding_before(Date::today - 5), @obj.outstanding_before(Date::today - 5)
        end
     
        should "determine labor cost" do
          assert_equal 0.4 * @task1.cost, @obj.labor_cost unless @obj.instance_of? Contract
          assert_equal 0.5 * @obj.cost, @obj.labor_cost if @obj.instance_of? Contract
        end
         
        should "determine labor cost with date cutoff" do
          assert_equal 0.5 * 0.4 * @task1.cost, @obj.labor_cost_before(Date::today - 5) unless @obj.instance_of? Contract
          assert_equal 0.5 * 0.5 * @obj.cost, @obj.labor_cost_before(Date::today - 5) if @obj.instance_of? Contract
        end
        
        should "determine material cost" do
          assert_equal (0.6 * @task1.cost).round(2), @obj.material_cost.round(2) unless @obj.instance_of? Contract
          assert_equal (0.5 * @obj.cost).round(2), @obj.material_cost.round(2) if @obj.instance_of? Contract
        end
        
        should "determine material cost with date cutoff" do
          assert_equal 0.5 * 0.6 * @task1.cost, @obj.material_cost_before(Date::today - 5) unless @obj.instance_of? Contract
          assert_equal 0.5 * 0.5 * @obj.cost, @obj.material_cost_before(Date::today - 5) if @obj.instance_of? Contract
        end
        
        should "determine percent complete" do
          assert_equal 50, @obj.percent_complete unless @obj.instance_of? Contract
          assert_equal (@obj.cost / @obj.estimated_cost), @obj.percent_complete_float if @obj.instance_of? Contract
        end
=end
      end
    end
  end
end
