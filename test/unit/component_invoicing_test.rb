require File.dirname(__FILE__) + '/../test_helper'

# These must be saved to DB - testing functions which rely on DB.sum()
class ComponentInvoicingTest < ActiveSupport::TestCase
  context "A component w/ actual costs" do
    setup do
      @project = Factory :project
      @obj = Factory :component

      @task = Factory :task
      
      @fc = Factory :fixed_cost_estimate, :raw_cost => 5, :component => @obj, :task => @task
      
      @q = Factory :quantity, :component => @obj, :value => 1
      @uc = Factory :unit_cost_estimate, :component => @obj, :task => @task, :unit_cost => 50000
      
      @c = Factory :contract, :project => @project, :component => @obj
      @b = Factory :bid, :contract => @c, :raw_cost => 50000
      @c.update_attributes(:active_bid => @b)
      
      [@obj, @project, @task, @fc, @q, @uc, @c, @b].each {|i| i.reload}
      
      @invoice = Factory :invoice, :project => @project, :date => Date::today
      @i_line = Factory( :invoice_line,
        :invoice => @invoice,
        :component => @obj,
        :labor_invoiced => 2,
        :labor_retainage => 2,
        :material_invoiced => 5,
        :material_retainage => 5
      )
# Pre-component-based invoicing stuff
=begin
      @fc_inv = Factory( :invoice_line, 
        :invoice => @invoice,
        :cost => @fc, 
        :labor_invoiced => 2, 
        :labor_retainage => 2, 
        :material_invoiced => 5, 
        :material_retainage => 5
      )
      @uc_inv = Factory( :invoice_line, 
        :invoice => @invoice,
        :cost => @uc, 
        :labor_invoiced => 20, 
        :labor_retainage => 20, 
        :material_invoiced => 50, 
        :material_retainage => 50
      )
      @c_inv = Factory( :invoice_line, 
        :invoice => @invoice,
        :cost => @c, 
        :labor_invoiced => 200, 
        :labor_retainage => 200, 
        :material_invoiced => 500, 
        :material_retainage => 500
      )      
=end
      @payment = Factory :payment, :project => @project, :date => Date::today
      @p_line = Factory( :payment_line,
        :payment => @payment,
        :component => @obj,
        :labor_paid => 1,
        :labor_retained => 1, 
        :material_paid => 3,
        :material_retained => 3
      )
=begin
      @fc_pay = Factory( :payment_line, 
        :payment => @payment,
        :cost => @fc, 
        :labor_paid => 1, 
        :labor_retained => 1, 
        :material_paid => 3, 
        :material_retained => 3
      )
      @uc_pay = Factory( :payment_line, 
        :payment => @payment,
        :cost => @uc, 
        :labor_paid => 10, 
        :labor_retained => 10, 
        :material_paid => 30, 
        :material_retained => 30
      )
      @c_pay = Factory( :payment_line, 
        :payment => @payment,
        :cost => @c, 
        :labor_paid => 100, 
        :labor_retained => 100, 
        :material_paid => 300, 
        :material_retained => 300
      )
=end
      [@obj, @project, @task, @fc, @q, @uc, @c, @b, @invoice, @payment].each {|i| i.reload}
    end
      
    should "aggregate invoiced" do
      assert_equal 2, @obj.labor_invoiced
      assert_equal 5, @obj.material_invoiced
      assert_equal 7, @obj.invoiced
    end

    should_eventually "aggregate invoiced with cutoff" do
      assert_equal 0, @c_inv.invoiced_before(Date::today - 5)
      assert_equal 0, @c.invoiced_before(Date::today - 5)
      
      assert_equal 0, @obj.labor_invoiced_before(Date::today - 5)
      assert_equal 0, @obj.material_invoiced_before(Date::today - 5)
      assert_equal 0, @obj.invoiced_before(Date::today - 5)
    end
    
    should "aggregate retainage" do
      assert_equal 2, @obj.labor_retainage
      assert_equal 5, @obj.material_retainage
      assert_equal 7, @obj.retainage
    end

    should "aggregate retainage with cutoff" do
      assert_equal 0, @obj.labor_retainage_before(Date::today - 5)
      assert_equal 0, @obj.material_retainage_before(Date::today - 5)
      assert_equal 0, @obj.retainage_before(Date::today - 5)
    end
            
    should "aggregate paid" do
      assert_equal 1, @obj.labor_paid
      assert_equal 3, @obj.material_paid
      assert_equal 4, @obj.paid 
    end

    should "aggregate paid with cutoff" do
      assert_equal 0, @obj.labor_paid_before(Date::today - 5)
      assert_equal 0, @obj.material_paid_before(Date::today - 5)
      assert_equal 0, @obj.paid_before(Date::today - 5)
    end
    
    should "aggregate retained" do
      assert_equal 1, @obj.labor_retained
      assert_equal 3, @obj.material_retained
      assert_equal 4, @obj.retained
    end
    
    should "aggregate retained with cutoff" do
      assert_equal 0, @obj.labor_retained_before(Date::today - 5)
      assert_equal 0, @obj.material_retained_before(Date::today - 5)
      assert_equal 0, @obj.retained_before(Date::today - 5)
    end
  end
end
