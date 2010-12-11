require File.dirname(__FILE__) + '/../test_helper'

class InvoiceTest < ActiveSupport::TestCase
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
end
