namespace :db do
  desc 'Provide a base load of randomly generated (but valid) data for development'
  task :seed => ['fixtures:load'] do

    Factory :user, :email => 'test@example.com', :password => 'password'
    (rand(10)+1).times { Factory :user }
    
    (rand(10)+1).times { 
      project = Factory :project 
      
      (rand(10)+1).times { Factory :laborer, :project => project }
      
      # Components
      (rand(10)+1).times { 
        c = Factory :component, :project => project 

        (rand(10)+1).times {
          c2 = Factory :component, :project => project, :parent => c
          c3 = Factory :component, :project => project, :parent => c2
        
          q1 = Factory :quantity, :component => c2
          q2 = Factory :quantity, :component => c3
          
          dq1 = Factory :derived_quantity, :parent_quantity => q1
          dq2 = Factory :derived_quantity, :parent_quantity => q2
          
          rand(5).times { Factory :fixed_cost_estimate, :component => c2 }
          rand(5).times { Factory :fixed_cost_estimate, :component => c3 }
   
          Factory :unit_cost_estimate, :quantity => q1
          Factory :unit_cost_estimate, :quantity => q2
          Factory :unit_cost_estimate, :quantity => dq1
          Factory :unit_cost_estimate, :quantity => dq2
        }
        
        quantities = []
        rand(5).times {
          quantities << Factory( :quantity, :component => c )     
        }
        
        quantities.each { |q|
          rand(5).times {
            dq = Factory :derived_quantity, :parent_quantity => q
            Factory :unit_cost_estimate, :quantity => dq
          }
          
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
      
      # Assign costs to tasks
      Task.all.each {|t|
        rand(10).times {
          l = Factory :labor_cost, :task => t
          (rand(5)+1).times {
            Factory :labor_cost_line, :labor_set => l
          }
        }
        rand(10).times {
          m = Factory :material_cost, :task => t
          (rand(5)+1).times {
            Factory :material_cost_line, :material_set => m
          }
        }
      }
      
      (rand(10)+1).times {
        contract = Factory :contract, :project => project
        
        (rand(10)+1).times {
          Factory :bid, :contract => contract
        }
        (rand(10)+1).times {
          Factory :contract_cost, :contract => contract
        }
      }
      
      # Deadlines
      (rand(4)+1).times {
        deadline = Factory :deadline, :project => project
        
        (rand(4)+1).times {
          Factory :relative_deadline, :parent_deadline => deadline
        }
      }
    }
    

    # login instructions
    puts "\n**************\n\nThe following accounts are available for use:\n\n"
    puts '  test@example.com (password: password)'
    puts "\n**************\n\n"

  end
end