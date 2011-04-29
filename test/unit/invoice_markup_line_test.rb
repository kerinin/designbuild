require 'test_helper'

class InvoiceMarkupLineTest < ActiveSupport::TestCase
  context "An Invoice Markup Line" do
    setup do
      @l = Factory :laborer, :bill_rate => 1
      @project = Factory :project, :labor_percent_retainage => 10, :material_percent_retainage => 20
      @markup = Factory :markup, :percent => 10
      @raw_component = @project.components.create! :name => 'raw component'
      @markup_component = @project.components.create! :name => 'markup component'
      
      @markup_component.markups << @markup
      
      @invoice = Factory :invoice, :project => @project
      @raw_line = Factory :invoice_line, :invoice => @invoice, :component => @raw_component, :labor_invoiced => 10, :labor_retainage => 100, :material_invoiced => 1000, :material_retainage => 10000
      @markup_line = Factory :invoice_line, :invoice => @invoice, :component => @markup_component, :labor_invoiced => 100000, :labor_retainage => 1000000, :material_invoiced => 10000000, :material_retainage => 100000000
      
      @obj = Factory :invoice_markup_line, :invoice => @invoice, :markup => @markup
    end

    should "have values" do
      assert @obj.valid?
      
      assert_not_nil @obj.labor_invoiced
      assert_not_nil @obj.material_invoiced
      assert_not_nil @obj.invoiced
    
      assert_not_nil @obj.labor_retainage
      assert_not_nil @obj.material_retainage
      assert_not_nil @obj.retainage
    end
        
    should "require a associated objects" do
      assert_raise ActiveRecord::RecordInvalid do
        Factory :invoice_markup_line, :invoice => nil
      end

      assert_raise ActiveRecord::RecordInvalid do
        Factory :invoice_markup_line, :markup => nil
      end
    end
    
    should "calculate values" do
      assert_equal 10000, @obj.labor_invoiced
      assert_equal 100000, @obj.labor_retainage
      assert_equal 1000000, @obj.material_invoiced
      assert_equal 10000000, @obj.material_retainage
    end
    
    should "sum values" do
      assert_equal 1010000, @obj.invoiced
      assert_equal 10100000, @obj.retainage
    end
    
    should "allow explicit value specification" do
      @obj.update_attributes :labor_invoiced => 0, :labor_retainage => 0, :material_invoiced => 0, :material_retainage => 0
      
      assert_equal 0, @obj.labor_invoiced
      assert_equal 0, @obj.labor_retainage
      assert_equal 0, @obj.material_invoiced
      assert_equal 0, @obj.material_retainage      
      
      assert_equal 0, @obj.invoiced
      assert_equal 0, @obj.retainage  
    end
  end
end
