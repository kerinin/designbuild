namespace :db do
  desc 'Provide a base load of randomly generated (but valid) data for development'
  task :seed => ['fixtures:load'] do

    Factory :user, :email => 'test@example.com', :password => 'password'
    6.times { Factory :user }
    
    4.times { 
      project = Factory :project 
      
      6.times { Factory :laborer, :project => project }
      
      # Components
      4.times { 
        c = Factory :component, :project => project 

        4.times {
          c2 = Factory :component, :project => project, :parent => c
          c3 = Factory :component, :project => project, :parent => c2
        
          q1 = Factory :quantity, :component => c2
          q2 = Factory :quantity, :component => c3
          
          dq1 = Factory :derived_quantity, :parent_quantity => q1
          dq2 = Factory :derived_quantity, :parent_quantity => q2
          
          2.times { Factory :fixed_cost_estimate, :component => c2 }
          2.times { Factory :fixed_cost_estimate, :component => c3 }
   
          Factory :unit_cost_estimate, :quantity => q1
          Factory :unit_cost_estimate, :quantity => q2
          Factory :unit_cost_estimate, :quantity => dq1
          Factory :unit_cost_estimate, :quantity => dq2
        }
        
        q1 = Factory :quantity, :component => c
        q2 = Factory :quantity, :component => c
        
        dq1 = Factory :derived_quantity, :parent_quantity => q1
        dq2 = Factory :derived_quantity, :parent_quantity => q2
        
        2.times { Factory :fixed_cost_estimate, :component => c }
        2.times { Factory :fixed_cost_estimate, :component => c }
        
        Factory :unit_cost_estimate, :quantity => q1
        Factory :unit_cost_estimate, :quantity => q2
        Factory :unit_cost_estimate, :quantity => dq1
        Factory :unit_cost_estimate, :quantity => dq2
      }
    }
    

    # login instructions
    puts "\n**************\n\nThe following accounts are available for use:\n\n"
    puts '  test@example.com (password: password)'
    puts "\n**************\n\n"

  end
end