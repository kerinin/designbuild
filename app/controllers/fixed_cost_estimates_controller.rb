class FixedCostEstimatesController < ApplicationController
  before_filter :get_project, :get_component
  
  # GET /fixed_cost_estimates
  # GET /fixed_cost_estimates.xml
  def index
    @fixed_cost_estimates = FixedCostEstimate.all

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
    @fixed_cost_estimate = FixedCostEstimate.new(params[:fixed_cost_estimate])

    respond_to do |format|
      if @fixed_cost_estimate.save
        format.html { redirect_to(project_component_fixed_cost_estimate_path(@project, @component, @fixed_cost_estimate), :notice => 'Fixed cost estimate was successfully created.') }
        format.xml  { render :xml => @fixed_cost_estimate, :status => :created, :location => @fixed_cost_estimate }
      else
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
        format.html { redirect_to(project_component_fixed_cost_estimate_path(@project, @component, @fixed_cost_estimate), :notice => 'Fixed cost estimate was successfully updated.') }
        format.xml  { head :ok }
      else
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
      format.html { redirect_to(project_component_fixed_cost_estimates_url(@project, @component)) }
      format.xml  { head :ok }
    end
  end
end
