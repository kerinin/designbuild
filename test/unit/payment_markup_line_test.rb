require 'test_helper'

class PaymentMarkupLineTest < ActiveSupport::TestCase
    context "A Payment Markup Line" do
      setup do
        @l = Factory :laborer, :bill_rate => 1
        @project = Factory :project, :labor_percent_retainage => 10, :material_percent_retainage => 20
        @markup = Factory :markup, :percent => 10
        @raw_component = @project.components.create! :name => 'raw component'
        @markup_component = @project.components.create! :name => 'markup component'

        @markup_component.markups << @markup

        @payment = Factory :payment, :project => @project
        @raw_line = Factory :payment_line, :payment => @payment, :component => @raw_component, :labor_paid => 10, :labor_retained => 100, :material_paid => 1000, :material_retained => 10000
        @markup_line = Factory :payment_line, :payment => @payment, :component => @markup_component, :labor_paid => 100000, :labor_retained => 1000000, :material_paid => 10000000, :material_retained => 100000000

        @obj = Factory :payment_markup_line, :payment => @payment, :markup => @markup
      end

      should "have values" do
        assert @obj.valid?

        assert_not_nil @obj.labor_paid
        assert_not_nil @obj.material_paid
        assert_not_nil @obj.paid

        assert_not_nil @obj.labor_retained
        assert_not_nil @obj.material_retained
        assert_not_nil @obj.retained
      end

      should "require a associated objects" do
        assert_raise ActiveRecord::RecordInvalid do
          Factory :payment_markup_line, :payment => nil
        end

        assert_raise ActiveRecord::RecordInvalid do
          Factory :payment_markup_line, :markup => nil
        end
      end

      should "calculate default values" do
        assert_equal 10000, @obj.labor_paid
        assert_equal 100000, @obj.labor_retained
        assert_equal 1000000, @obj.material_paid
        assert_equal 10000000, @obj.material_retained
      end

      should "sum values" do
        assert_equal 1010000, @obj.paid
        assert_equal 10100000, @obj.retained
      end
      
      should "allow explicit value specification" do
        @obj.update_attributes :labor_paid => 0, :labor_retained => 0, :material_paid => 0, :material_retained => 0
        
        assert_equal 0, @obj.labor_paid
        assert_equal 0, @obj.labor_retained
        assert_equal 0, @obj.material_paid
        assert_equal 0, @obj.material_retained      
        
        assert_equal 0, @obj.paid
        assert_equal 0, @obj.retained  
      end
    end
  end