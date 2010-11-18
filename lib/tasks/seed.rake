namespace :db do
  desc 'Provide a base load of randomly generated (but valid) data for development'
  task :seed => ['fixtures:load'] do

    Factory :user, :email => 'test@example.com', :password => 'password'
    (rand(10)+1).times { Factory :user }
    
    (rand(5)+5).times { 
      project = Factory :project 
      
      suppliers = []
      4.times {
        suppliers << Factory( :supplier, :project => project )
      }
      
      (rand(10)+1).times { Factory :laborer, :project => project }
      
      # Components
      (rand(10)+1).times { 
        c = Factory :component, :project => project 

        (rand(10)+1).times {
          c2 = Factory :component, :project => project, :parent => c
          c3 = Factory :component, :project => project, :parent => c2
        
          q1 = Factory :quantity, :component => c2
          q2 = Factory :quantity, :component => c3
          
          rand(5).times { Factory :fixed_cost_estimate, :component => c2 }
          rand(5).times { Factory :fixed_cost_estimate, :component => c3 }
   
          Factory :unit_cost_estimate, :quantity => q1
          Factory :unit_cost_estimate, :quantity => q2
        }
        
        quantities = []
        rand(5).times {
          quantities << Factory( :quantity, :component => c )     
        }
        
        quantities.each { |q| 
          rand(5).times {
            Factory :unit_cost_estimate, :quantity => q
          }
        }
        
        rand(5).times { Factory :fixed_cost_estimate, :component => c }
      }
      
      # Tasks
      (rand(5)+1).times {
        Factory :task, :project => project
      }
      
      # Assign cost estimates to tasks
      rand(UnitCostEstimate.count).times {
        cost = UnitCostEstimate.unassigned.first
        cost.task = Task.find rand(Task.count)+1 unless cost.nil?
        cost.save! unless cost.nil?
      }
      rand(FixedCostEstimate.count).times {
        cost = FixedCostEstimate.unassigned.first
        cost.task = Task.find rand(Task.count)+1 unless cost.nil?
        cost.save! unless cost.nil?
      }
      
      if rand(2) == 1
        # Assign costs to tasks
        project.tasks.each {|t|
          (rand(5)+5).times {
            l = Factory :labor_cost, :task => t
            (rand(5)+1).times {
              Factory :labor_cost_line, :labor_set => l, :laborer => Laborer.all[rand(Laborer.count)]
            }
          }
          (rand(5)+5).times {
            m = (rand(3) == 1) ? Factory( :material_cost, :task => t, :cost => nil, :supplier => suppliers.random ) : Factory( :material_cost, :task => t, :supplier => suppliers.random )
            (rand(5)+1).times {
              Factory :material_cost_line, :material_set => m
            }
          }
        }
      
        (rand(5)+5).times {
          contract = Factory :contract, :project => project
        
          (rand(10)+1).times {
            Factory :bid, :contract => contract
          }
          (rand(10)+1).times {
            Factory :contract_cost, :contract => contract
          }
        }
      
        # Deadlines
        (rand(5)+5).times {
          deadline = Factory :deadline, :project => project
        
          (rand(4)).times {
            Factory :relative_deadline, :parent_deadline => deadline
          }
        }
        
        # Assign tasks to deadlines
        Task.all.each do |task|
          task.deadline = case rand(3)
          when 0
            Deadline.find(rand(Deadline.count)+1)
          when 1
            RelativeDeadline.find(rand(RelativeDeadline.count)+1)
          end
        end
      end
    }
    

    # login instructions
    puts "\n**************\n\nThe following accounts are available for use:\n\n"
    puts '  test@example.com (password: password)'
    puts "\n**************\n\n"

  end
end
