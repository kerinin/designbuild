class FixedCostEstimatesController < ApplicationController
  #before_filter :get_component
  before_filter :get_objects
  
  def add_to_task
    @task = Task.find(params[:task_id])
    @fixed_cost_estimate = FixedCostEstimate.find params[:id]
    @task.fixed_cost_estimates << @fixed_cost_estimate unless @task.fixed_cost_estimates.include? @fixed_cost_estimate
    
    respond_to do |format|
      format.html { redirect_to estimated_costs_task_path(@task) }
    end
  end
  
  def remove_from_task
    @task = Task.find(params[:task_id])
    
    @fixed_cost_estimate = FixedCostEstimate.find params[:id]
    @task.fixed_cost_estimates.delete @fixed_cost_estimate
    
    respond_to do |format|
      format.html { redirect_to estimated_costs_task_path(@task) }
    end
  end
  
  # GET /fixed_cost_estimates
  # GET /fixed_cost_estimates.xml
  def index
    @fixed_cost_estimates = FixedCostEstimate.scoped

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @fixed_cost_estimates }
    end
  end

  # GET /fixed_cost_estimates/1
  # GET /fixed_cost_estimates/1.xml
  def show
    @fixed_cost_estimate = FixedCostEstimate.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @fixed_cost_estimate }
    end
  end

  # GET /fixed_cost_estimates/new
  # GET /fixed_cost_estimates/new.xml
  def new
    @fixed_cost_estimate = FixedCostEstimate.new

    respond_to do |format|
      format.js
      format.html # new.html.erb
      format.xml  { render :xml => @fixed_cost_estimate }
    end
  end

  # GET /fixed_cost_estimates/1/edit
  def edit
    @fixed_cost_estimate = FixedCostEstimate.find(params[:id])
  end

  # POST /fixed_cost_estimates
  # POST /fixed_cost_estimates.xml
  def create
    task_name = params[:fixed_cost_estimate].delete(:task_name)
    @fixed_cost_estimate = FixedCostEstimate.new(params[:fixed_cost_estimate])
    @fixed_cost_estimate.component = @component
    @fixed_cost_estimate.task_name = task_name unless task_name.nil?

    respond_to do |format|
      if @fixed_cost_estimate.save
        format.js
        format.html { redirect_to(@component, :notice => 'Fixed cost estimate was successfully created.') }
        format.xml  { render :xml => @fixed_cost_estimate, :status => :created, :location => @fixed_cost_estimate }
      else
        format.js
        format.html { render :action => "new" }
        format.xml  { render :xml => @fixed_cost_estimate.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /fixed_cost_estimates/1
  # PUT /fixed_cost_estimates/1.xml
  def update
    @fixed_cost_estimate = FixedCostEstimate.find(params[:id])

    respond_to do |format|
      if @fixed_cost_estimate.update_attributes(params[:fixed_cost_estimate])
        format.js
        format.html { redirect_to(@fixed_cost_estimate.component, :notice => 'Fixed cost estimate was successfully updated.') }
        format.xml  { head :ok }
      else
        format.js
        format.html { render :action => "edit" }
        format.xml  { render :xml => @fixed_cost_estimate.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /fixed_cost_estimates/1
  # DELETE /fixed_cost_estimates/1.xml
  def destroy
    @fixed_cost_estimate = FixedCostEstimate.find(params[:id])
    @fixed_cost_estimate.destroy

    respond_to do |format|
      format.html { redirect_to [@project, @component] }
      format.xml  { head :ok }
    end
  end
  
  private
  
  def get_objects
    @fixed_cost_estimate = FixedCostEstimate.find(params[:id]) if params.has_key? :id
    @project = Project.find(params[:project_id]) if params.has_key? :project_id
    @component = Component.find(params[:component_id]) if params.has_key? :component_id
    
    @component ||= @fixed_cost_estimate.component unless @fixed_cost_estimate.nil?
    @project ||= @component.project unless @component.nil?
  end
end
