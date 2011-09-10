namespace :db do
  desc 'Provide a base load of randomly generated (but valid) data for development'
  task :seed => ['fixtures:load'] do

    Factory :user, :email => 'test@example.com', :password => 'password'
    (rand(10)+1).times { Factory :user }

    suppliers = []
    6.times {
      suppliers << Factory( :supplier )
    }
        
    (rand(5)+5).times { 
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
      project.components.each do |component|
        rand(component.unit_cost_estimates.count).to_i.times {
          cost = component.unit_cost_estimates.unassigned.first
          cost.task = project.tasks[ rand(project.tasks.count) ] unless cost.nil?
          cost.save! unless cost.nil?
        }
        rand(component.fixed_cost_estimates.count).to_i.times {
          cost = component.fixed_cost_estimates.unassigned.first
          cost.task = project.tasks[ rand(project.tasks.count) ] unless cost.nil?
          cost.save! unless cost.nil?
        }
      end
      
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
            m = (rand(3) == 1) ? Factory( :material_cost, :task => t, :raw_cost => nil, :supplier => suppliers.random ) : Factory( :material_cost, :task => t, :supplier => suppliers.random )
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
        
        # Add markups
        #rand(3).times {
        #  Factory :markup, :projects => [project]
        #}
      end
    }
    

    # login instructions
    puts "\n**************\n\nThe following accounts are available for use:\n\n"
    puts '  test@example.com (password: password)'
    puts "\n**************\n\n"

  end
end
