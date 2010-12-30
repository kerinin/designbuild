namespace :points do
  desc 'Generate points from paper_trail for project'
  task :project => :environment do
    DatePoint.where(:source_type => 'Project').delete_all
    
    Project.all.each do |obj|
      obj.versions.all.each do |version|
        unless version.object.nil?
          data = YAML::load version.object
          ep = obj.estimated_cost_points.find_or_initialize_by_date(version.created_at.to_date)
          ep.series = :estimated_cost
          ep.value = 0
          ep.value += data['estimated_unit_cost'] unless data['estimated_unit_cost'].nil?
          ep.value += data['estimated_fixed_cost'] unless data['estimated_fixed_cost'].nil?
          ep.value += data['estimated_contract_cost'] unless data['estimated_contract_cost'].nil?
          ep.save! if ep.value > 0
          
          pp = obj.projected_cost_points.find_or_initialize_by_date(version.created_at.to_date)
          pp.series = :projected_cost
          pp.value = data['projected_cost']
          pp.save! unless pp.value.nil? || pp.value == 0
          
          cp = obj.cost_to_date_points.find_or_initialize_by_date(version.created_at.to_date)
          cp.series = :cost_to_date
          cp.value = 0
          cp.value += data['labor_cost'] unless data['labor_cost'].nil?
          cp.value += data['material_cost'] unless data['material_cost'].nil?
          cp.value += data['contract_cost'] unless data['contract_cost'].nil?
          cp.save! unless cp.value.nil? || cp.value == 0
        end
      end
    end
  end
  
  desc 'Generate points from paper_trail for component'
  task :component => :environment do
    DatePoint.where(:source_type => 'Component').delete_all
    
    Component.all.each do |obj|
      obj.versions.all.each do |version|
        unless version.object.nil?
          data = YAML::load version.object
          ep = obj.estimated_cost_points.find_or_initialize_by_date(version.created_at.to_date)
          ep.series = :estimated_cost
          ep.value = 0
          ep.value += data['estimated_unit_cost'] unless data['estimated_unit_cost'].nil?
          ep.value += data['estimated_fixed_cost'] unless data['estimated_fixed_cost'].nil?
          ep.value += data['estimated_contract_cost'] unless data['estimated_contract_cost'].nil?
          ep.save! if ep.value > 0
        end
      end
    end
  end
  
  desc 'Generate points from paper_trail for task'
  task :task => :environment do
    DatePoint.where(:source_type => 'Task').delete_all
    
    Task.all.each do |obj|
      obj.versions.all.each do |version|
        unless version.object.nil?
          data = YAML::load version.object
          ep = obj.estimated_cost_points.find_or_initialize_by_date(version.created_at.to_date)
          ep.series = :estimated_cost
          ep.value = 0
          ep.value += data['estimated_unit_cost'] unless data['estimated_unit_cost'].nil?
          ep.value += data['estimated_fixed_cost'] unless data['estimated_fixed_cost'].nil?
          ep.value += data['estimated_contract_cost'] unless data['estimated_contract_cost'].nil?
          ep.save! if ep.value > 0
          
          pp = obj.projected_cost_points.find_or_initialize_by_date(version.created_at.to_date)
          pp.series = :projected_cost
          pp.value = data['projected_cost']
          pp.save! unless pp.value.nil? || pp.value == 0
          
          cp = obj.cost_to_date_points.find_or_initialize_by_date(version.created_at.to_date)
          cp.series = :cost_to_date
          cp.value = 0
          cp.value += data['labor_cost'] unless data['labor_cost'].nil?
          cp.value += data['material_cost'] unless data['material_cost'].nil?
          cp.value += data['contract_cost'] unless data['contract_cost'].nil?
          cp.save! unless cp.value.nil? || cp.value == 0
        end
      end
    end
  end
  
  desc 'Generate points from paper_trail for contract'
  task :contract => :environment do
    DatePoint.where(:source_type => 'Contract').delete_all
    
    Contract.all.each do |obj|
      obj.versions.all.each do |version|
        unless version.object.nil?
          data = YAML::load version.object
          ep = obj.estimated_cost_points.find_or_initialize_by_date(version.created_at.to_date)
          ep.series = :estimated_cost
          ep.value = 0
          ep.value += data['estimated_raw_cost'] unless data['estimated_raw_cost'].nil?
          ep.save! if ep.value > 0
          
          cp = obj.cost_to_date_points.find_or_initialize_by_date(version.created_at.to_date)
          cp.series = :cost_to_date
          cp.value = 0
          cp.value += data['labor_cost'] unless data['labor_cost'].nil?
          cp.value += data['material_cost'] unless data['material_cost'].nil?
          cp.value += data['contract_cost'] unless data['contract_cost'].nil?
          cp.save! unless cp.value.nil? || cp.value == 0
        end
      end
    end
  end
end

