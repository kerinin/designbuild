require File.dirname(__FILE__) + '/../test_helper'

class DatePointTest < ActiveSupport::TestCase
=begin
  context "A Date Point assigned to a project" do
    setup do
      @source = Factory.build :project
      
      @e2 = @source.estimated_cost_points.build :date => Date::today - 5, :value => 100, :source => @source, :series => :estimated_cost
      @e3 = @source.estimated_cost_points.build :date => Date::today, :value => 100, :source => @source, :series => :estimated_cost
      @e1 = @source.estimated_cost_points.build :date => Date::today - 10, :value => 100, :source => @source, :series => :estimated_cost
      
      @p2 = @source.projected_cost_points.build :date => Date::today - 5, :value => 100, :source => @source, :series => :projected_cost
      @p3 = @source.projected_cost_points.build :date => Date::today, :value => 100, :source => @source, :series => :projected_cost
      @p1 = @source.projected_cost_points.build :date => Date::today - 10, :value => 100, :source => @source, :series => :projected_cost
      
      @t2 = @source.cost_to_date_points.build :date => Date::today - 5, :value => 100, :source => @source, :series => :cost_to_date
      @t3 = @source.cost_to_date_points.build :date => Date::today, :value => 100, :source => @source, :series => :cost_to_date
      @t1 = @source.cost_to_date_points.build :date => Date::today - 10, :value => 100, :source => @source, :series => :cost_to_date
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
      [@source, @e1].each {|i| i.save!}
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
      @source.save!
      
      assert_raise ActiveRecord::RecordInvalid do
        @source.estimated_cost_points.create! :date => Date::today, :value => 200
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
      [@source, @e1, @e2, @e3, @p1, @p2, @p3, @t1, @t2, @t3].each {|i| i.save!}
      @source.reload
      
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

    should "update points on update" do 
      [@source, @e1, @e2, @e3, @p1, @p2, @p3, @t1, @t2, @t3].each {|i| i.save!}
      @source.reload
      
      assert_equal 3, @source.estimated_cost_points.count
      assert_equal 3, @source.projected_cost_points.count
      assert_equal 3, @source.cost_to_date_points.count

      @component = @source.components.create! :name => 'component'
      @task = @source.tasks.create! :name => 'task'
            
      @fc = @component.fixed_cost_estimates.create! :name => 'fixed cost', :raw_cost => 200
      @task.fixed_cost_estimates << @fc
      @mc = @task.material_costs.create! :date => Date::today, :raw_cost => 200, :supplier => Factory(:supplier)
      
      assert_equal 200, @source.estimated_cost_points.last.value
      assert_equal 200, @source.projected_cost_points.last.value
      assert_equal 200, @source.cost_to_date_points.last.value
    end
        
    should "create points on update" do 
      [@e3, @p3, @t3].each {|i| i.update_attributes(:date => Date::today - 1)}
      @source.reload
      
      assert_equal 3, @source.estimated_cost_points.count
      assert_equal 3, @source.projected_cost_points.count
      assert_equal 3, @source.cost_to_date_points.count

      @component = @source.components.create! :name => 'component'
      @task = @source.tasks.create! :name => 'task'
            
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
    
    should "not create points on update if labeled point exists" do 
      @e3.label = 'Label'
      @p3.label = 'Label'
      @t3.label = 'Label'
      [@source, @e1, @e2, @e3, @p1, @p2, @p3, @t1, @t2, @t3].each {|i| i.save!}
      @source.reload
      
      assert_equal 3, @source.estimated_cost_points.count
      assert_equal 3, @source.projected_cost_points.count
      assert_equal 3, @source.cost_to_date_points.count

      @component = @source.components.create! :name => 'component'
      @task = @source.tasks.create! :name => 'task'
            
      @fc = @component.fixed_cost_estimates.create! :name => 'fixed cost', :raw_cost => 200
      @task.fixed_cost_estimates << @fc
      @mc = @task.material_costs.create! :date => Date::today, :raw_cost => 200, :supplier => Factory(:supplier)
      
      assert_equal 3, @source.estimated_cost_points.count
      assert_equal 3, @source.projected_cost_points.count
      assert_equal 3, @source.cost_to_date_points.count
      
      assert_equal 100, @source.estimated_cost_points.last.value
      assert_equal 100, @source.projected_cost_points.last.value
      assert_equal 100, @source.cost_to_date_points.last.value
    end
  end

  context "A Date Point assigned to a component" do
    setup do
      @project = Factory :project
      @source = @project.components.create! :name => 'component', :project => @project

      @e2 = @source.estimated_cost_points.build :date => Date::today - 5, :value => 100, :source => @source, :series => :estimated_cost
      @e3 = @source.estimated_cost_points.build :date => Date::today, :value => 100, :source => @source, :series => :estimated_cost
      @e1 = @source.estimated_cost_points.build :date => Date::today - 10, :value => 100, :source => @source, :series => :estimated_cost
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
      [@project, @source].each {|i| i.save!}
      
      assert_raise ActiveRecord::RecordInvalid do
        @source.estimated_cost_points.create! :date => Date::today, :value => 200
      end
    end
        
    should "assign series" do
      assert_equal :estimated_cost, @e1.series
      assert_equal :estimated_cost, @e2.series
      assert_equal :estimated_cost, @e3.series    
    end
    
    should "order by date" do
      [@project, @source, @e1, @e2, @e3].each {|i| i.save!}
      
      assert_equal @e2, @source.estimated_cost_points[1]
      assert_equal @e3, @source.estimated_cost_points[2]
      assert_equal @e1, @source.estimated_cost_points[0]  
    end
  
    should "create points on update" do
      [@project, @source, @e1, @e2, @e3].each {|i| i.save!}
      
      assert_equal 3, @source.estimated_cost_points.count
      
      @source.fixed_cost_estimates.create! :name => 'fixed cost', :raw_cost => 200
      
      assert_equal 4, @source.estimated_cost_points.count
      
      assert_equal 200, @source.estimated_cost_points.last.value
    end
    
    

    should "update points on update" do 
      [@project, @source, @e1, @e2, @e3].each {|i| i.save!}
      
      assert_equal 3, @source.estimated_cost_points.count

      @source.fixed_cost_estimates.create! :name => 'fixed cost', :raw_cost => 200
      
      assert_equal 200, @source.estimated_cost_points.last.value
    end
        
    should "create points on update" do 
      @e3.date = Date::today - 1
      [@project, @source, @e1, @e2, @e3].each {|i| i.save!}
      
      assert_equal 3, @source.estimated_cost_points.count

      @source.fixed_cost_estimates.create! :name => 'fixed cost', :raw_cost => 200
      
      assert_equal 4, @source.estimated_cost_points.count
      
      assert_equal 200, @source.estimated_cost_points.last.value
    end
    
    should "not create points on update if labeled point exists" do 
      @e3.label = 'Label'
      [@project, @source, @e1, @e2, @e3].each {|i| i.save!}
      
      assert_equal 3, @source.estimated_cost_points.count

      @source.fixed_cost_estimates.create! :name => 'fixed cost', :raw_cost => 200
      
      assert_equal 3, @source.estimated_cost_points.count
      
      assert_equal 100, @source.estimated_cost_points.last.value
    end
    
    
  end
=end
  context "A Date Point assigned to a task" do
    setup do
      @project = Factory :project
      @component = @project.components.create! :name => 'component', :project => @project
      @fc = @component.fixed_cost_estimates.create! :name => 'fixed cost', :raw_cost => 200, :component => @component
      @source = @project.tasks.create! :name => 'task', :project => @project
      
      @e2 = @source.estimated_cost_points.build :date => Date::today - 5, :value => 100, :source => @source, :series => :estimated_cost
      @e3 = @source.estimated_cost_points.build :date => Date::today, :value => 100, :source => @source, :series => :estimated_cost
      @e1 = @source.estimated_cost_points.build :date => Date::today - 10, :value => 100, :source => @source, :series => :estimated_cost
      
      @p2 = @source.projected_cost_points.build :date => Date::today - 5, :value => 100, :source => @source, :series => :projected_cost
      @p3 = @source.projected_cost_points.build :date => Date::today, :value => 100, :source => @source, :series => :projected_cost
      @p1 = @source.projected_cost_points.build :date => Date::today - 10, :value => 100, :source => @source, :series => :projected_cost
      
      @t2 = @source.cost_to_date_points.build :date => Date::today - 5, :value => 100, :source => @source, :series => :cost_to_date
      @t3 = @source.cost_to_date_points.build :date => Date::today, :value => 100, :source => @source, :series => :cost_to_date
      @t1 = @source.cost_to_date_points.build :date => Date::today - 10, :value => 100, :source => @source, :series => :cost_to_date

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
      [@project, @source].each {|i| i.save!}
      
      assert_raise ActiveRecord::RecordInvalid do
        Factory :date_point, :series => nil, :source => @source
      end
    end
    
    should "require a date" do
      [@project, @source].each {|i| i.save!}
      
      assert_raise ActiveRecord::RecordInvalid do
        Factory :date_point, :date => nil, :source => @source
      end
    end
    
    should "require a value" do
      [@project, @source].each {|i| i.save!}
      
      assert_raise ActiveRecord::RecordInvalid do
        Factory :date_point, :value => nil, :source => @source
      end
    end

    should "require unique date" do
      [@project, @source].each {|i| i.save!}
      
      assert_raise ActiveRecord::RecordInvalid do
        @source.estimated_cost_points.create! :date => Date::today, :value => 200
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
      [@project, @source, @e1, @e2, @e3, @p1, @p2, @p3, @t1, @t2, @t3].each {|i| i.save!}
      @source.reload
      
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

    should "update points on update" do 
      [@source, @e1, @e2, @e3, @p1, @p2, @p3, @t1, @t2, @t3].each {|i| i.save!}
      @source.reload
      
      assert_equal 3, @source.estimated_cost_points.count
      assert_equal 3, @source.projected_cost_points.count
      assert_equal 3, @source.cost_to_date_points.count

      @source.fixed_cost_estimates << @fc
      @mc = @source.material_costs.create! :date => Date::today, :raw_cost => 200, :supplier => Factory(:supplier)

      assert_equal 3, @source.estimated_cost_points.count
      assert_equal 3, @source.projected_cost_points.count
      assert_equal 3, @source.cost_to_date_points.count
                  
      assert_equal 200, @source.estimated_cost_points.last.value
      assert_equal 200, @source.projected_cost_points.last.value
      assert_equal 200, @source.cost_to_date_points.last.value
      
      assert_equal 200, @project.estimated_cost_points.last.value
      assert_equal 200, @project.projected_cost_points.last.value
      assert_equal 200, @project.cost_to_date_points.last.value
    end
        
    should "create points on update" do 
      [@source, @e1, @e2, @e3, @p1, @p2, @p3, @t1, @t2, @t3].each {|i| i.save!}
      [@e3, @p3, @t3].each {|i| i.update_attributes(:date => Date::today - 1)}
      @source.reload
      
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
      
      assert_equal 200, @project.estimated_cost_points.last.value
      assert_equal 200, @project.projected_cost_points.last.value
      assert_equal 200, @project.cost_to_date_points.last.value
    end
    
    should "not create points on update if labeled point exists" do 
      @e3.label = 'Label'
      @p3.label = 'Label'
      @t3.label = 'Label'
      [@source, @e1, @e2, @e3, @p1, @p2, @p3, @t1, @t2, @t3].each {|i| i.save!}
      @source.reload
      
      assert_equal 3, @source.estimated_cost_points.count
      assert_equal 3, @source.projected_cost_points.count
      assert_equal 3, @source.cost_to_date_points.count

      @source.fixed_cost_estimates << @fc
      @mc = @source.material_costs.create! :date => Date::today, :raw_cost => 200, :supplier => Factory(:supplier)
      
      assert_equal 3, @source.estimated_cost_points.count
      assert_equal 3, @source.projected_cost_points.count
      assert_equal 3, @source.cost_to_date_points.count
      
      assert_equal 100, @source.estimated_cost_points.last.value
      assert_equal 100, @source.projected_cost_points.last.value
      assert_equal 100, @source.cost_to_date_points.last.value
    end
  end
=begin
  context "A Date Point assigned to a contract" do
    setup do
      @project = Factory :project
      @component = @project.components.create! :name => 'component', :project => @project
      @fc = @component.fixed_cost_estimates.create! :name => 'fixed cost', :raw_cost => 200, :component => @component
      @source = @project.contracts.create! :name => 'contract', :component => @component, :project => @project
      
      @e2 = @source.estimated_cost_points.build :date => Date::today - 5, :value => 100, :source => @source, :series => :estimated_cost
      @e3 = @source.estimated_cost_points.build :date => Date::today, :value => 100, :source => @source, :series => :estimated_cost
      @e1 = @source.estimated_cost_points.build :date => Date::today - 10, :value => 100, :source => @source, :series => :estimated_cost

      @t2 = @source.cost_to_date_points.build :date => Date::today - 5, :value => 100, :source => @source, :series => :cost_to_date
      @t3 = @source.cost_to_date_points.build :date => Date::today, :value => 100, :source => @source, :series => :cost_to_date
      @t1 = @source.cost_to_date_points.build :date => Date::today - 10, :value => 100, :source => @source, :series => :cost_to_date

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
      [@project, @component, @source].each {|i| i.save!}
      
      assert_raise ActiveRecord::RecordInvalid do
        Factory :date_point, :source => nil
      end
    end
    
    should "require a series" do
      [@project, @component, @source].each {|i| i.save!}
      
      assert_raise ActiveRecord::RecordInvalid do
        Factory :date_point, :series => nil, :source => @source
      end
    end
    
    should "require a date" do
      [@project, @component, @source].each {|i| i.save!}
      
      assert_raise ActiveRecord::RecordInvalid do
        Factory :date_point, :date => nil, :source => @source
      end
    end
    
    should "require a value" do
      [@project, @component, @source].each {|i| i.save!}
      
      assert_raise ActiveRecord::RecordInvalid do
        Factory :date_point, :value => nil, :source => @source
      end
    end

    should "require unique date" do
      [@project, @component, @source].each {|i| i.save!}
      
      assert_raise ActiveRecord::RecordInvalid do
        @source.estimated_cost_points.create! :date => Date::today, :value => 200
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
      [@project, @component, @source, @e1, @e2, @e3, @t1, @t2, @t3].each {|i| i.save!}
      @source.reload
      
      assert_equal @e2, @source.estimated_cost_points[1]
      assert_equal @e3, @source.estimated_cost_points[2]
      assert_equal @e1, @source.estimated_cost_points[0]

      assert_equal @t2, @source.cost_to_date_points[1]
      assert_equal @t3, @source.cost_to_date_points[2]
      assert_equal @t1, @source.cost_to_date_points[0]   
    end
    
    should "update points on update" do 
      [@source, @e1, @e2, @e3, @t1, @t2, @t3].each {|i| i.save!}
      @source.reload
    
      assert_equal 3, @source.estimated_cost_points.count
      assert_equal 3, @source.cost_to_date_points.count

      @bid = @source.bids.create! :contractor => 'foo', :raw_cost => 200, :date => Date::today
      @source.update_attributes :active_bid => @bid
      @source.costs.create! :date => Date::today, :raw_cost => 200
    
      assert_equal 200, @source.estimated_cost_points.last.value
      assert_equal 200, @source.cost_to_date_points.last.value
      
      assert_equal 400, @project.estimated_cost_points.last.value
      assert_equal 400, @component.estimated_cost_points.last.value
      assert_equal 200, @project.cost_to_date_points.last.value
    end
      
    should "create points on update" do 
      [@source, @e1, @e2, @e3, @t1, @t2, @t3].each {|i| i.save!}
      [@e3, @t3].each {|i| i.update_attributes(:date => Date::today - 1)}
      @source.reload
    
      assert_equal 3, @source.estimated_cost_points.count
      assert_equal 3, @source.cost_to_date_points.count

      @bid = @source.bids.create! :contractor => 'foo', :raw_cost => 200, :date => Date::today
      @source.update_attributes :active_bid => @bid
      @source.costs.create! :date => Date::today, :raw_cost => 200
    
      assert_equal 4, @source.estimated_cost_points.count
      assert_equal 4, @source.cost_to_date_points.count
    
      assert_equal 200, @source.estimated_cost_points.last.value
      assert_equal 200, @source.cost_to_date_points.last.value
      
      assert_equal 400, @project.estimated_cost_points.last.value
      assert_equal 400, @component.estimated_cost_points.last.value
      assert_equal 200, @project.cost_to_date_points.last.value
    end
  
    should "not create points on update if labeled point exists" do 
      @e3.label = 'Label'
      @t3.label = 'Label'
      [@source, @e1, @e2, @e3, @t1, @t2, @t3].each {|i| i.save!}
      @source.reload
    
      assert_equal 3, @source.estimated_cost_points.count
      assert_equal 3, @source.cost_to_date_points.count

      @bid = @source.bids.create! :contractor => 'foo', :raw_cost => 200, :date => Date::today
      @source.update_attributes :active_bid => @bid
      @source.costs.create! :date => Date::today, :raw_cost => 200
    
      assert_equal 3, @source.estimated_cost_points.count
      assert_equal 3, @source.cost_to_date_points.count
    
      assert_equal 100, @source.estimated_cost_points.last.value
      assert_equal 100, @source.cost_to_date_points.last.value
    end
  end
=end
end
