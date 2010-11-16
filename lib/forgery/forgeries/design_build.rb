class Forgery::DesignBuild < Forgery

  def self.component_name
    dictionaries[:components].random
  end
  
  def self.contract_name
    dictionaries[:contracts].random
  end
  
  def self.cost_name
    dictionaries[:costs].random
  end
  
  def self.deadline_name
    dictionaries[:deadlines].random
  end
  
  def self.quantity_name
    dictionaries[:quantities].random
  end
  
  def self.task_name
    dictionaries[:tasks].random
  end
  
  def self.unit_name
    dictionaries[:units].random
  end

  def self.project_name
    dictionaries[:projects].random
  end
end