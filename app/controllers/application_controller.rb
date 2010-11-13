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
  end
end
