class UnitCostEstimatesController < ApplicationController
  before_filter :get_component
  
  # GET /unit_cost_estimates
  # GET /unit_cost_estimates.xml
  def index
    @unit_cost_estimates = UnitCostEstimate.all

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

    respond_to do |format|
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
    @unit_cost_estimate = UnitCostEstimate.new(params[:unit_cost_estimate])
    @unit_cost_estimate.component = @component

    respond_to do |format|
      if @unit_cost_estimate.save
        format.html { redirect_to([@component, @unit_cost_estimate], :notice => 'Unit cost estimate was successfully created.') }
        format.xml  { render :xml => @unit_cost_estimate, :status => :created, :location => @unit_cost_estimate }
      else
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
        format.html { redirect_to([@component, @unit_cost_estimate], :notice => 'Unit cost estimate was successfully updated.') }
        format.xml  { head :ok }
      else
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
      format.html { redirect_to(component_unit_cost_estimates_url(@component)) }
      format.xml  { head :ok }
    end
  end
end
