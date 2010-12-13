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
    
    should_eventually "allow a version" do
      @i = Factory :invoice, :project_version => 3, :project => @project
      assert_equal 3, @i.project_version
      assert_equal '3', @i.versioned_project.name
    end
    
    should_eventually "default to latest project version" do
      assert_equal '4', @obj.versioned_project.name
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
  context "and invoice state machine" do
    setup do
      @project = Factory :project, :labor_percent_retainage => 10, :material_percent_retainage => 20
      @component = Factory :component, :project => @project
      @fc = Factory :fixed_cost_estimate, :component => @component, :raw_cost => 1
      @q = Factory :quantity, :component => @component, :value => 1
      @uc = Factory :unit_cost_estimate, :component => @component, :unit_cost => 10
      @c = Factory :contract, :component => @component, :project => @project, :active_bid => Factory(:bid, :raw_cost => 100)
      
      @obj = Factory :invoice, :project => @project, :state => 'new'
    end
    
    should "start as new" do
      assert_equal 'new', @obj.state
    end
    
    should "-> date set if date specified" do
      @obj.date = Date::today
      @obj.advance
      
      assert_equal 'date_specified', @obj.state
    end
    
    should "not -> date set if date not specified" do
      @obj.advance
      
      assert_equal 'new', @obj.state
    end
    
    should "populate line items when -> date_specified" do
      @obj.date = Date::today
      @obj.advance
      
      assert_equal 3, @obj.lines
    end
    
    should "-> retainage unexpected if unexpected" do
      @obj.date = Date::today
      @obj.advance
      
      @li = Factory :invoice_line, :invoice => @obj, :labor_invoiced => 10, :labor_retainage => 10
      @mi = Factory :invoice_line, :invoice => @obj, :material_invoiced => 10, :material_retainage => 10
      @obj.advance
      
      assert_equal 'retainage_unexpected', @obj.state
    end
    
    should "-> costs specified if retainage specified" do
      @obj.date = Date::today
      @obj.advance
      
      @li = Factory :invoice_line, :invoice => @obj, :labor_invoiced => 9, :labor_retainage => 1
      @mi = Factory :invoice_line, :invoice => @obj, :material_invoiced => 8, :material_retainage => 2
      @obj.advance
      
      assert_equal 'costs_specified', @obj.state
    end
    
    should "retainage unexpected -> complete if template specified" do
      @obj.date = Date::today
      @obj.advance
      
      @li = Factory :invoice_line, :invoice => @obj, :labor_invoiced => 10, :labor_retainage => 10
      @mi = Factory :invoice_line, :invoice => @obj, :material_invoiced => 10, :material_retainage => 10
      @obj.advance
      
      @obj.template = 'blah'
      @obj.advance
      
      assert_equal 'complete', @obj.state
    end
    
    should "cost specified -> complete if template specified" do
      @obj.date = Date::today
      @obj.advance
      
      @li = Factory :invoice_line, :invoice => @obj, :labor_invoiced => 9, :labor_retainage => 1
      @mi = Factory :invoice_line, :invoice => @obj, :material_invoiced => 8, :material_retainage => 2
      @obj.advance

      @obj.template = 'blah'
      @obj.advance
      
      assert_not_equal 'complete', @obj.state
    end
    
    should "not -> complete if template not specified" do
      @obj.date = Date::today
      @obj.advance
      
      @li = Factory :invoice_line, :invoice => @obj, :labor_invoiced => 10, :labor_retainage => 10
      @mi = Factory :invoice_line, :invoice => @obj, :material_invoiced => 10, :material_retainage => 10
      @obj.advance
      
      @obj.template = nil
      @obj.advance
      
      assert_not_equal 'complete', @obj.state
    end
  end
end
