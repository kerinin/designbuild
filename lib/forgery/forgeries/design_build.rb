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
  
  def self.supplier_name
    dictionaries[:suppliers].random
  end
  
  def self.markup_name
    dictionaries[:markups].random
  end
  
  def self.resource_name
    dictionaries[:resource_name].random
  end
end
