class ApplicationController < ActionController::Base
  protect_from_forgery
  
  private
  
  def get_project
    @project = Project.find(params[:project_id])
  end
  
  def get_component
    @component = Component.find(params[:component_id])
    @project = @component.project
  end
  
  def get_task
    @task = Task.find(params[:task_id])
    @project = @task.project
  end
  
  def get_contract
    @contract = Contract.find(params[:contract_id])
    @project = @contract.project
  end
  
  def get_deadline
    @deadline = Deadline.find(params[:deadline_id])
    @project = @deadline.project
  end
  
  def get_labor_set
    @labor_cost = LaborCost.find(params[:labor_cost_id])
    @task = @labor_cost.task
    @project = @task.project
  end
  
  def get_material_set
    @material_cost = MaterialCost.find(params[:material_cost_id])
    @task = @material_cost.task
    @project = @task.project
    @supplier = @material_cost.supplier
  end
  
  private
  
  class << self
  
    attr_reader :parents
  
    def parent_resources(*parents)
      @parents = parents
    end
  
  end

  def parent_id(parent)
    request.path_parameters["#{ parent }_id"]
  end

  def parent_type
    self.class.parents.detect { |parent| parent_id(parent) }
  end
  
  def parent_class
    parent_type && parent_type.to_s.classify.constantize
  end
   
  def parent_object
    parent_class && parent_class.find_by_id(parent_id(parent_type))
  end
end
