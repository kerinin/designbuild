class ApplicationController < ActionController::Base
  protect_from_forgery
  
  before_filter :authenticate_user!
  before_filter :check_redirect, :set_context
  
  cache_sweeper :project_sweeper
  cache_sweeper :resource_sweeper
  
  private
  
  def redirect_from_session_or(*args)
    if session.has_key?( :redirect_to )
      redirect = session[:redirect_to]
      session[:redirect_to] = nil
      redirect_to redirect
    else
      redirect_to(*args) unless session.has_key?( :redirect)
    end
  end
  
  def redirect_pop_or(url)
    if session.has_key?( :redirect_to )
      redirect = session[:redirect_to]
      session[:redirect_to] = nil
      return redirect
    else
      return url
    end
  end
  
  def set_context
    @context = params.has_key?(:context) ? params[:context].to_sym : nil
  end
  
  def check_redirect
    session[:redirect_to] = params[:redirect_to] if params.has_key?(:redirect_to)
  end
  
  def get_project
    @project = Project.find(params[:project_id])
  end
  
  def get_project_or_component
    @project = Project.find(params[:project_id]) if params.has_key? :project_id
    @component = Component.find(params[:component_id]) if params.has_key? :component_id
    @project ||= @component.project
  end
  
  def get_component
    @component = Component.find(params[:component_id])
    @project = @component.project
  end
  
  def get_task
    @task = Task.find(params[:task_id]) if params.has_key? :task_id
    @project = @task.project unless @task.nil?
  end
  
  def get_contract
    @contract = Contract.find(params[:contract_id])
    @project = @contract.project
  end

  def get_invoice
    @invoice = Invoice.find(params[:invoice_id])
    @project = @invoice.project
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
end
