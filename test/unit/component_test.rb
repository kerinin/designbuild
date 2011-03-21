require File.dirname(__FILE__) + '/../test_helper'

class ComponentTest < ActiveSupport::TestCase
  context "A component" do
    setup do
      @tag1 = Factory.build :tag
      @tag2 = Factory.build :tag
      
      @project = Factory.build :project
      @parent = @project.components.build :name => 'parent', :project => @project
      #@obj = Factory :component, :tags => [@tag1, @tag2], :parent => @parent

      @obj = @project.components.build :name => 'obj', :tags => [@tag1, @tag2], :project => @project
      
      #@sub1 = Factory :component, :parent => @obj
      @sub1 = @project.components.build :name => 'sub1', :project => @project
      #@sub2 = Factory :component, :parent => @obj
      @sub2 = @project.components.build :name => 'sub2', :project => @project
      #@subsub = Factory :component, :parent => @sub1
      @subsub = @project.components.build :name => 'subsub', :project => @project
      #@q1 = Factory :quantity, :component => @obj, :value => 1
      
      @task = @project.tasks.build :name => 'test', :project => @project
      @mc = @task.material_costs.build :component => @obj, :date => Date::today, :supplier => Factory(:supplier), :raw_cost => 0, :task => @task
      @lc = @task.labor_costs.build :component => @obj, :date => Date::today, :task => @task, :percent_complete => 0
    end

    should "be valid" do
      assert @obj.valid?
    end
    
    should "have values" do
      assert_not_nil @obj.name
    end
      
    should "require a project" do
      assert_raise ActiveRecord::RecordInvalid do
        Factory :component, :project => nil
      end
    end
    
    should_eventually "have multiple alternates" do
    end
    
    should "have multiple tags" do
      [@tag1, @tag2, @project, @parent, @obj].each {|i| i.save!}
      
      assert_contains @obj.tags, @tag1
      assert_contains @obj.tags, @tag2
      assert_contains @tag1.components, @obj
      assert_contains @tag2.components, @obj
    end
    
    should "return estimated cost nil if no estimates" do
      @obj2 = Factory :component
      assert_equal 0, @obj2.estimated_raw_cost
    end
    
    context "with hierarchy" do
      setup do
        [@project, @parent, @obj, @sub1, @sub2, @subsub].each {|i| i.save!}
        
        @obj.update_attributes :parent => @parent
        @sub1.update_attributes :parent => @obj
        @sub2.update_attributes :parent => @obj
        @subsub.update_attributes :parent => @sub1
      end

      should "allow multiple material costs" do
        assert_contains @obj.reload.material_costs, @mc
      end

      should "allow multiple labor costs" do
        assert_contains @obj.reload.labor_costs, @lc
      end

      should_eventually "auto-assign material costs" do
      end

      should_eventually "auto-assign labor costs" do
      end
            
      should "have a parent component" do
        assert_equal @obj.parent, @parent
      end
        
      should "have multiple subcomponents" do
        assert_contains @obj.children.all, @sub1
        assert_contains @obj.children.all, @sub2
      end
      
      should "return ancestors" do
        assert_contains @subsub.ancestors.all, @sub1
        assert_contains @subsub.ancestors.all, @obj
        assert_contains @subsub.ancestors.all, @parent
      end

      should "return descendants" do
        [@project, @parent, @obj, @sub1, @sub2, @subsub].each {|i| i.save!}
        @obj.update_attributes :parent => @parent
        @sub1.update_attributes :parent => @obj
        @sub2.update_attributes :parent => @obj
        @subsub.update_attributes :parent => @sub1

        assert_contains @parent.descendants.all, @obj
        assert_contains @parent.descendants.all, @sub1
        assert_contains @parent.descendants.all, @sub2
        assert_contains @parent.descendants.all, @subsub
      end
      
      context "with estimates" do
        setup do
          [@project, @parent, @obj, @sub1, @sub2, @subsub].each {|i| i.save!}

          @q1 = @obj.quantities.create! :name => 'q1', :component => @obj, :value => 1
          #@q2 = Factory :quantity, :component => @obj, :value => 2
          @q2 = @obj.quantities.create! :name => 'q2', :component => @obj, :value => 2

          #@fc1 = Factory :fixed_cost_estimate, :component => @obj, :raw_cost => 1
          @fc1 = @obj.fixed_cost_estimates.create! :name => 'fc1', :component => @obj, :raw_cost => 1
          #@fc2 = Factory :fixed_cost_estimate, :component => @obj, :raw_cost => 10
          @fc2 = @obj.fixed_cost_estimates.create! :name => 'fc2', :component => @obj, :raw_cost => 10
          #@fc3 = Factory :fixed_cost_estimate, :component => @sub1, :raw_cost => 100000
          @fc3 = @sub1.fixed_cost_estimates.create! :name => 'fc3', :component => @sub1, :raw_cost => 100000
          #@uc1 = Factory :unit_cost_estimate, :quantity => @q1, :unit_cost => 100, :drop => 0 # x1
          @uc1 = @obj.unit_cost_estimates.create! :name => 'uc1', :component => @obj, :quantity => @q1, :unit_cost => 100, :drop => 0
          #@uc2 = Factory :unit_cost_estimate, :quantity => @q2, :unit_cost => 1000, :drop => 0 # x2
          @uc2 = @obj.unit_cost_estimates.create! :name => 'uc2', :component => @obj, :quantity => @q2, :unit_cost => 1000, :drop => 0

          #@c1 = Factory :contract, :component => @obj, :active_bid => Factory(:bid, :raw_cost =>  1000000)
          @c1 = @obj.contracts.create! :name => 'c1', :component => @obj, :project => @project, :active_bid => Factory(:bid, :raw_cost =>  1000000)
          #@c2 = Factory :contract, :component => @obj, :active_bid => Factory(:bid, :raw_cost =>  10000000)
          @c2 = @obj.contracts.create! :name => 'c2', :component => @obj, :project => @project, :active_bid => Factory(:bid, :raw_cost =>  10000000)
          #@c3 = Factory :contract, :component => @sub1, :active_bid => Factory(:bid, :raw_cost => 100000000)
          @c3 = @sub1.contracts.create! :name => 'c3', :component => @sub1, :project => @project, :active_bid => Factory(:bid, :raw_cost => 100000000)
          #@c4 = Factory :contract, :component => @sub2, :active_bid => Factory(:bid, :raw_cost => 1000000000)
          @c4 = @sub2.contracts.create! :name => 'c4', :component => @sub2, :project => @project, :active_bid => Factory(:bid, :raw_cost => 1000000000)
        end


        should "have multiple quantities" do
          assert_contains @obj.quantities, @q1
          assert_contains @obj.quantities, @q2
        end

        should "have multiple fixed costs" do
          assert_contains @obj.fixed_cost_estimates, @fc1
          assert_contains @obj.fixed_cost_estimates, @fc2
        end    

        should "have multiple unit costs" do
          assert_contains @obj.unit_cost_estimates, @uc1
          assert_contains @obj.unit_cost_estimates, @uc2
        end

        should "have multiple contracts" do
          assert_contains @obj.contracts, @c1
          assert_contains @obj.contracts, @c2
        end

        should "aggregate all costs" do
          assert_contains @obj.cost_estimates, @fc1
          assert_contains @obj.cost_estimates, @fc2
          assert_contains @obj.cost_estimates, @uc1
          assert_contains @obj.cost_estimates, @uc2
        end
  
        should "aggregate estimated costs" do        
          assert_equal 1111102111, @obj.reload.estimated_raw_cost
        end
      end
    end
  end
end
