class ApplicationController < ActionController::Base
  protect_from_forgery
  
  private
  
  def get_project
    @project = Project.find(params[:project_id])
  end
  
  def get_component
    @component = Component.find(params[:component_id])
  end
  
  def get_task
    @task = Task.find(params[:task_id])
  end
  
  def get_contract
    @contract = Contract.find(params[:contract_id])
  end
  
  def get_deadline
    @deadline = Deadline.find(params[:deadline_id])
  end
end
