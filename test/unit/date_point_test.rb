require File.dirname(__FILE__) + '/../test_helper'

class DatePointTest < ActiveSupport::TestCase
=begin
  context "A Date Point assigned to a project" do
    setup do
      @source = Factory :project
      
      @e2 = @source.estimated_cost_points.create! :date => Date::today - 5, :value => 100
      @e3 = @source.estimated_cost_points.create! :date => Date::today - 1, :value => 100
      @e1 = @source.estimated_cost_points.create! :date => Date::today - 10, :value => 100
      
      @p2 = @source.projected_cost_points.create! :date => Date::today - 5, :value => 100
      @p3 = @source.projected_cost_points.create! :date => Date::today - 1, :value => 100
      @p1 = @source.projected_cost_points.create! :date => Date::today - 10, :value => 100
      
      @t2 = @source.cost_to_date_points.create! :date => Date::today - 5, :value => 100
      @t3 = @source.cost_to_date_points.create! :date => Date::today - 1, :value => 100
      @t1 = @source.cost_to_date_points.create! :date => Date::today - 10, :value => 100
    end
    
    should "be valid" do
      assert @e1.valid?
      assert @e2.valid?
      assert @e3.valid?
      
      assert @p1.valid?
      assert @p2.valid?
      assert @p3.valid?
      
      assert @t1.valid?
      assert @t2.valid?
      assert @t3.valid?
    end
    
    should "have values" do
      assert_not_nil @e1.date
      assert_not_nil @e1.value
      assert_not_nil @e1.source
      assert_not_nil @e1.series
    end
    
    should "have a source" do
      assert_equal @e1.source, @source
      assert_equal @p1.source, @source
      assert_equal @t1.source, @source
    end
    
    should "require a source" do
      assert_raise ActiveRecord::RecordInvalid do
        Factory :date_point, :source => nil
      end
    end
    
    should "require a series" do
      assert_raise ActiveRecord::RecordInvalid do
        Factory :date_point, :series => nil, :source => @source
      end
    end
    
    should "require a date" do
      assert_raise ActiveRecord::RecordInvalid do
        Factory :date_point, :date => nil, :source => @source
      end
    end
    
    should "require a value" do
      assert_raise ActiveRecord::RecordInvalid do
        Factory :date_point, :value => nil, :source => @source
      end
    end

    should "require unique date" do
      assert_raise ActiveRecord::RecordInvalid do
        @source.estimated_cost_points.create! :date => Date::today - 1, :value => 200
      end
    end
        
    should "assign series" do
      assert_equal :estimated_cost, @e1.series
      assert_equal :estimated_cost, @e2.series
      assert_equal :estimated_cost, @e3.series
      
      assert_equal :projected_cost, @p1.series
      assert_equal :projected_cost, @p2.series
      assert_equal :projected_cost, @p3.series
      
      assert_equal :cost_to_date, @t1.series
      assert_equal :cost_to_date, @t2.series
      assert_equal :cost_to_date, @t3.series     
    end
    
    should "order by date" do
      assert_equal @e2, @source.estimated_cost_points[1]
      assert_equal @e3, @source.estimated_cost_points[2]
      assert_equal @e1, @source.estimated_cost_points[0]
      
      assert_equal @p2, @source.projected_cost_points[1]
      assert_equal @p3, @source.projected_cost_points[2]
      assert_equal @p1, @source.projected_cost_points[0]
      
      assert_equal @t2, @source.cost_to_date_points[1]
      assert_equal @t3, @source.cost_to_date_points[2]
      assert_equal @t1, @source.cost_to_date_points[0]   
    end
    
    should "create points on update" do
      @component = @source.components.create! :name => 'component'
      @task = @source.tasks.create! :name => 'task'
      
      assert_equal 3, @source.estimated_cost_points.count
      assert_equal 3, @source.projected_cost_points.count
      assert_equal 3, @source.cost_to_date_points.count
      
      @fc = @component.fixed_cost_estimates.create! :name => 'fixed cost', :raw_cost => 200
      @task.fixed_cost_estimates << @fc
      @mc = @task.material_costs.create! :date => Date::today, :raw_cost => 200, :supplier => Factory(:supplier)
      
      assert_equal 4, @source.estimated_cost_points.count
      assert_equal 4, @source.projected_cost_points.count
      assert_equal 4, @source.cost_to_date_points.count
      
      assert_equal 200, @source.estimated_cost_points.last.value
      assert_equal 200, @source.projected_cost_points.last.value
      assert_equal 200, @source.cost_to_date_points.last.value
    end
  end

  context "A Date Point assigned to a component" do
    setup do
      @project = Factory :project
      @source = @project.components.create! :name => 'component'
      
      @e2 = @source.estimated_cost_points.create! :date => Date::today - 5, :value => 100
      @e3 = @source.estimated_cost_points.create! :date => Date::today - 1, :value => 100
      @e1 = @source.estimated_cost_points.create! :date => Date::today - 10, :value => 100
    end
    
    should "be valid" do
      assert @e1.valid?
      assert @e2.valid?
      assert @e3.valid?
    end
    
    should "have values" do
      assert_not_nil @e1.date
      assert_not_nil @e1.value
      assert_not_nil @e1.source
      assert_not_nil @e1.series
    end
    
    should "have a source" do
      assert_equal @e1.source, @source
    end
    
    should "require a source" do
      assert_raise ActiveRecord::RecordInvalid do
        Factory :date_point, :source => nil
      end
    end
    
    should "require a series" do
      assert_raise ActiveRecord::RecordInvalid do
        Factory :date_point, :series => nil, :source => @source
      end
    end
    
    should "require a date" do
      assert_raise ActiveRecord::RecordInvalid do
        Factory :date_point, :date => nil, :source => @source
      end
    end
    
    should "require a value" do
      assert_raise ActiveRecord::RecordInvalid do
        Factory :date_point, :value => nil, :source => @source
      end
    end

    should "require unique date" do
      assert_raise ActiveRecord::RecordInvalid do
        @source.estimated_cost_points.create! :date => Date::today - 1, :value => 200
      end
    end
        
    should "assign series" do
      assert_equal :estimated_cost, @e1.series
      assert_equal :estimated_cost, @e2.series
      assert_equal :estimated_cost, @e3.series    
    end
    
    should "order by date" do
      assert_equal @e2, @source.estimated_cost_points[1]
      assert_equal @e3, @source.estimated_cost_points[2]
      assert_equal @e1, @source.estimated_cost_points[0]  
    end
    
    should "create points on update" do
      assert_equal 4, @source.estimated_cost_points.count
      
      @source.fixed_cost_estimates.create! :name => 'fixed cost', :raw_cost => 200
      
      assert_equal 4, @source.estimated_cost_points.count
      
      assert_equal 200, @source.estimated_cost_points.last.value
    end
  end
 
  context "A Date Point assigned to a task" do
    setup do
      @project = Factory :project
      @component = @project.components.create! :name => 'component'
      @fc = @component.fixed_cost_estimates.create! :name => 'fixed cost', :raw_cost => 200
      @source = @project.tasks.create! :name => 'task'
      
      @e2 = @source.estimated_cost_points.create! :date => Date::today - 5, :value => 100
      @e3 = @source.estimated_cost_points.create! :date => Date::today - 1, :value => 100
      @e1 = @source.estimated_cost_points.create! :date => Date::today - 10, :value => 100
      
      @p2 = @source.projected_cost_points.create! :date => Date::today - 5, :value => 100
      @p3 = @source.projected_cost_points.create! :date => Date::today - 1, :value => 100
      @p1 = @source.projected_cost_points.create! :date => Date::today - 10, :value => 100
      
      @t2 = @source.cost_to_date_points.create! :date => Date::today - 5, :value => 100
      @t3 = @source.cost_to_date_points.create! :date => Date::today - 1, :value => 100
      @t1 = @source.cost_to_date_points.create! :date => Date::today - 10, :value => 100
    end
    
    should "be valid" do
      assert @e1.valid?
      assert @e2.valid?
      assert @e3.valid?
      
      assert @p1.valid?
      assert @p2.valid?
      assert @p3.valid?
      
      assert @t1.valid?
      assert @t2.valid?
      assert @t3.valid?
    end
    
    should "have values" do
      assert_not_nil @e1.date
      assert_not_nil @e1.value
      assert_not_nil @e1.source
      assert_not_nil @e1.series
    end
    
    should "have a source" do
      assert_equal @e1.source, @source
      assert_equal @p1.source, @source
      assert_equal @t1.source, @source
    end
    
    should "require a source" do
      assert_raise ActiveRecord::RecordInvalid do
        Factory :date_point, :source => nil
      end
    end
    
    should "require a series" do
      assert_raise ActiveRecord::RecordInvalid do
        Factory :date_point, :series => nil, :source => @source
      end
    end
    
    should "require a date" do
      assert_raise ActiveRecord::RecordInvalid do
        Factory :date_point, :date => nil, :source => @source
      end
    end
    
    should "require a value" do
      assert_raise ActiveRecord::RecordInvalid do
        Factory :date_point, :value => nil, :source => @source
      end
    end

    should "require unique date" do
      assert_raise ActiveRecord::RecordInvalid do
        @source.estimated_cost_points.create! :date => Date::today - 1, :value => 200
      end
    end
        
    should "assign series" do
      assert_equal :estimated_cost, @e1.series
      assert_equal :estimated_cost, @e2.series
      assert_equal :estimated_cost, @e3.series
      
      assert_equal :projected_cost, @p1.series
      assert_equal :projected_cost, @p2.series
      assert_equal :projected_cost, @p3.series
      
      assert_equal :cost_to_date, @t1.series
      assert_equal :cost_to_date, @t2.series
      assert_equal :cost_to_date, @t3.series     
    end
    
    should "order by date" do
      assert_equal @e2, @source.estimated_cost_points[1]
      assert_equal @e3, @source.estimated_cost_points[2]
      assert_equal @e1, @source.estimated_cost_points[0]
      
      assert_equal @p2, @source.projected_cost_points[1]
      assert_equal @p3, @source.projected_cost_points[2]
      assert_equal @p1, @source.projected_cost_points[0]
      
      assert_equal @t2, @source.cost_to_date_points[1]
      assert_equal @t3, @source.cost_to_date_points[2]
      assert_equal @t1, @source.cost_to_date_points[0]   
    end
    
    should "create points on update" do
      assert_equal 3, @source.estimated_cost_points.count
      assert_equal 3, @source.projected_cost_points.count
      assert_equal 3, @source.cost_to_date_points.count
      
      @source.fixed_cost_estimates << @fc
      @mc = @source.material_costs.create! :date => Date::today, :raw_cost => 200, :supplier => Factory(:supplier)
      
      assert_equal 4, @source.estimated_cost_points.count
      assert_equal 4, @source.projected_cost_points.count
      assert_equal 4, @source.cost_to_date_points.count
      
      assert_equal 200, @source.estimated_cost_points.last.value
      assert_equal 200, @source.projected_cost_points.last.value
      assert_equal 200, @source.cost_to_date_points.last.value
    end
  end
=end
  context "A Date Point assigned to a contract" do
    setup do
      @project = Factory :project
      @component = @project.components.create! :name => 'component'
      @fc = @component.fixed_cost_estimates.create! :name => 'fixed cost', :raw_cost => 200
      @source = @project.contracts.create! :name => 'contract'
      
      @e2 = @source.estimated_cost_points.create! :date => Date::today - 5, :value => 100
      @e3 = @source.estimated_cost_points.create! :date => Date::today - 1, :value => 100
      @e1 = @source.estimated_cost_points.create! :date => Date::today - 10, :value => 100
      
      @t2 = @source.cost_to_date_points.create! :date => Date::today - 5, :value => 100
      @t3 = @source.cost_to_date_points.create! :date => Date::today - 1, :value => 100
      @t1 = @source.cost_to_date_points.create! :date => Date::today - 10, :value => 100
    end
    
    should "be valid" do
      assert @e1.valid?
      assert @e2.valid?
      assert @e3.valid?
      
      assert @t1.valid?
      assert @t2.valid?
      assert @t3.valid?
    end
    
    should "have values" do
      assert_not_nil @e1.date
      assert_not_nil @e1.value
      assert_not_nil @e1.source
      assert_not_nil @e1.series
    end
    
    should "have a source" do
      assert_equal @e1.source, @source
      assert_equal @t1.source, @source
    end
    
    should "require a source" do
      assert_raise ActiveRecord::RecordInvalid do
        Factory :date_point, :source => nil
      end
    end
    
    should "require a series" do
      assert_raise ActiveRecord::RecordInvalid do
        Factory :date_point, :series => nil, :source => @source
      end
    end
    
    should "require a date" do
      assert_raise ActiveRecord::RecordInvalid do
        Factory :date_point, :date => nil, :source => @source
      end
    end
    
    should "require a value" do
      assert_raise ActiveRecord::RecordInvalid do
        Factory :date_point, :value => nil, :source => @source
      end
    end

    should "require unique date" do
      assert_raise ActiveRecord::RecordInvalid do
        @source.estimated_cost_points.create! :date => Date::today - 1, :value => 200
      end
    end
        
    should "assign series" do
      assert_equal :estimated_cost, @e1.series
      assert_equal :estimated_cost, @e2.series
      assert_equal :estimated_cost, @e3.series

      assert_equal :cost_to_date, @t1.series
      assert_equal :cost_to_date, @t2.series
      assert_equal :cost_to_date, @t3.series     
    end
    
    should "order by date" do
      assert_equal @e2, @source.estimated_cost_points[1]
      assert_equal @e3, @source.estimated_cost_points[2]
      assert_equal @e1, @source.estimated_cost_points[0]

      assert_equal @t2, @source.cost_to_date_points[1]
      assert_equal @t3, @source.cost_to_date_points[2]
      assert_equal @t1, @source.cost_to_date_points[0]   
    end
    
    should "create points on update" do
      assert_equal 3, @source.estimated_cost_points.count
      assert_equal 3, @source.cost_to_date_points.count
      
      @component.contracts << @source
      @source.costs.create! :date => Date::today, :raw_cost => 200
      
      assert_equal 4, @source.estimated_cost_points.count
      assert_equal 4, @source.cost_to_date_points.count
      
      assert_equal 200, @source.estimated_cost_points.last.value
      assert_equal 200, @source.cost_to_date_points.last.value
    end
  end

end
