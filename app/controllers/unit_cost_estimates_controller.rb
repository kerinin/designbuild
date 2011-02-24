class UnitCostEstimatesController < ApplicationController
  #before_filter :get_component
  before_filter :get_objects
  
  def add_to_task
    @task = Task.find(params[:task_id])
    @unit_cost_estimate = UnitCostEstimate.find params[:id]
    @unit_cost_estimate.update_attributes :task => @task
    
    respond_to do |format|
      format.html { redirect_to estimated_costs_task_path(@task) }
    end
  end
  
  def remove_from_task
    @task = Task.find(params[:task_id])
    
    @unit_cost_estimate = UnitCostEstimate.find params[:id]
    @unit_cost_estimate.update_attributes :task => nil
    
    respond_to do |format|
      format.html { redirect_to estimated_costs_task_path(@task) }
    end
  end
  
  # GET /unit_cost_estimates
  # GET /unit_cost_estimates.xml
  def index
    @unit_cost_estimates = UnitCostEstimate.scoped

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @unit_cost_estimates }
    end
  end

  # GET /unit_cost_estimates/1
  # GET /unit_cost_estimates/1.xml
  def show
    @unit_cost_estimate = UnitCostEstimate.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @unit_cost_estimate }
    end
  end

  # GET /unit_cost_estimates/new
  # GET /unit_cost_estimates/new.xml
  def new
    @unit_cost_estimate = UnitCostEstimate.new
    @unit_cost_estimate.component_id = @component.id unless @component.nil?

    respond_to do |format|
      format.js
      format.html # new.html.erb
      format.xml  { render :xml => @unit_cost_estimate }
    end
  end

  # GET /unit_cost_estimates/1/edit
  def edit
    @unit_cost_estimate = UnitCostEstimate.find(params[:id])
  end

  # POST /unit_cost_estimates
  # POST /unit_cost_estimates.xml
  def create
    task_name = params[:unit_cost_estimate].delete(:task_name)
    @unit_cost_estimate = UnitCostEstimate.new(params[:unit_cost_estimate])
    @unit_cost_estimate.component = @component
    @unit_cost_estimate.task_name = task_name unless task_name.nil?

    respond_to do |format|
      if @unit_cost_estimate.save
        format.js
        format.html { redirect_to( @component, :notice => 'Unit cost estimate was successfully created.') }
        format.xml  { render :xml => @unit_cost_estimate, :status => :created, :location => @unit_cost_estimate }
      else
        format.js
        format.html { render :action => "new" }
        format.xml  { render :xml => @unit_cost_estimate.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /unit_cost_estimates/1
  # PUT /unit_cost_estimates/1.xml
  def update
    @unit_cost_estimate = UnitCostEstimate.find(params[:id])

    respond_to do |format|
      if @unit_cost_estimate.update_attributes(params[:unit_cost_estimate])
        format.js
        format.html { redirect_to([@component, @unit_cost_estimate], :notice => 'Unit cost estimate was successfully updated.') }
        format.xml  { head :ok }
      else
        format.js
        format.html { render :action => "edit" }
        format.xml  { render :xml => @unit_cost_estimate.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /unit_cost_estimates/1
  # DELETE /unit_cost_estimates/1.xml
  def destroy
    @unit_cost_estimate = UnitCostEstimate.find(params[:id])
    @unit_cost_estimate.destroy

    respond_to do |format|
      format.html { redirect_to [@project, @component] }
      format.xml  { head :ok }
    end
  end
  
  private
  
  def get_objects
    @unit_cost_estimate = UnitCostEstimate.find(params[:id]) if params.has_key? :id
    @project = Project.find(params[:project_id]) if params.has_key? :project_id
    @component = Component.find(params[:component_id]) if params.has_key? :component_id
    
    @component ||= @unit_cost_estimate.component unless @unit_cost_estimate.nil?
    @project ||= @component.project unless @component.nil?
  end
end
