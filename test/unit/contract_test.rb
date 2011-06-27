require File.dirname(__FILE__) + '/../test_helper'

class ContractTest < ActiveSupport::TestCase
  context "A Contract" do
    setup do
      @project = Factory.build :project
      
      @component = @project.components.build :name => 'component', :project => @project
      
      @obj = @component.contracts.build :name => 'contract', :project => @project, :component => @component
      @contract2 = @component.contracts.build :name => 'contract2', :project => @project, :component => @component
    end
    
    should "be valid" do
      assert @obj.valid?
    end
  
    should "have values" do
      assert_not_nil @obj.name
    end

    should "require a component" do
      assert_raise ActiveRecord::RecordInvalid do
        Factory :contract, :component => nil
      end
    end
  
    context "with costs" do
      setup do
        @c1 = @obj.costs.build :raw_cost => 1, :date => Date::today
        @c2 = @obj.costs.build :raw_cost => 10, :date => Date::today
        @b1 = @obj.bids.build :contractor => 'foo', :raw_cost => 0, :date => Date::today
        @b2 = @obj.bids.build :contractor => 'foo', :raw_cost => 0, :date => Date::today
        @obj.active_bid = @b2
      end
              
      should "allow multiple costs" do
        assert_contains @obj.costs, @c1
        assert_contains @obj.costs, @c2
      end
      
      should "allow multiple bids" do
        assert_contains @obj.bids, @b1
        assert_contains @obj.bids, @b2
      end

      should "allow a component" do
        assert_equal @component, @obj.component
      end
          
      should "allow an active bid" do
        assert_equal @obj.active_bid, @b2
      end
    end

    #-------------------Markups
    
    context "with markups" do
      setup do
        [@project, @component].each {|i| i.save!}

        @pm = @project.markups.create :name => 'project markup', :percent => 100
        @cm = @component.markups.create :name => 'component markup', :percent => 100
      end
               
    
      should "inherit project markups" do
        assert_contains @obj.reload.markups, @pm
        assert_contains @contract2.reload.markups, @pm
      end
      
      should "inherit component markups" do
        assert_contains @obj.reload.markups, @cm
      end
      
      should "cascade project markups" do
        @markup = Factory :markup
        @project.markups << @markup
        
        assert_contains @obj.reload.markups, @markup
        assert_contains @contract2.reload.markups, @markup
      end
      
      should "cascade component markups" do
        @markup = Factory :markup
        @component.markups << @markup
        
        assert_contains @obj.reload.markups, @markup
      end
      
      context "and costs" do
        setup do
          @c1 = @obj.costs.create! :raw_cost => 1, :date => Date::today
          @c2 = @obj.costs.create! :raw_cost => 10, :date => Date::today
          @b1 = @obj.bids.create! :contractor => 'foo', :raw_cost => 0, :date => Date::today
          @b2 = @obj.bids.create! :contractor => 'foo', :raw_cost => 100, :date => Date::today
          @obj.update_attributes :active_bid => @b2
          
          @obj.reload
        end
        
        #-------------------CALCULATIONS
     
        should "return current bid cost" do
          assert_equal 100, @obj.estimated_raw_cost
        end
           
        should "aggregate costs" do
          assert_equal 11, @obj.raw_cost
        end

        should "aggregate costs with cutoff" do
          assert_equal 0, @obj.raw_cost_before(Date::today - 5)
        end
      end
    end
    
    
    # ------------------Invoicing
    should_eventually "determine labor_percent" do
    end
    
    should_eventually "determine material_percent" do
    end
  end
end
