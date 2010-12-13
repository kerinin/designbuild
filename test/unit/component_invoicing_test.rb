require File.dirname(__FILE__) + '/../test_helper'

class ComponentTest < ActiveSupport::TestCase
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
      
      @invoice = Factory :invoice, :project => @project
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
      @payment = Factory :payment, :project => @project
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
      [@obj, @project, @task, @fc, @q, @uc, @c, @b, @invoice, @fc_inv, @uc_inv, @c_inv, @payment, @fc_pay, @uc_inv, @c_inv, @payment].each {|i| i.reload}
    end
      
    should "aggregate invoiced" do
      assert_equal 700, @c_inv.invoiced
      assert_contains @c.invoice_lines, @c_inv
      assert_equal 700, @c.invoiced
      
      assert_equal 222, @obj.labor_invoiced
      assert_equal 555, @obj.material_invoiced
      assert_equal 777, @obj.invoiced
    end

    should "aggregate retainage" do
      assert_equal 222, @obj.labor_retainage
      assert_equal 555, @obj.material_retainage
      assert_equal 777, @obj.retainage
    end
        
    should "aggregate paid" do
      assert_equal 111, @obj.labor_paid
      assert_equal 333, @obj.material_paid
      assert_equal 444, @obj.paid 
    end

    should "aggregate retained" do
      assert_equal 111, @obj.labor_retained
      assert_equal 333, @obj.material_retained
      assert_equal 444, @obj.retained
    end
  end
end
