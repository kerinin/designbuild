class LaborCostsController < ApplicationController
  before_filter :get_task
  
  # GET /labor_costs
  # GET /labor_costs.xml
  def index
    @labor_costs = LaborCost.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @labor_costs }
    end
  end

  # GET /labor_costs/1
  # GET /labor_costs/1.xml
  def show
    @labor_cost = LaborCost.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @labor_cost }
    end
  end

  # GET /labor_costs/new
  # GET /labor_costs/new.xml
  def new
    @labor_cost = LaborCost.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @labor_cost }
    end
  end

  # GET /labor_costs/1/edit
  def edit
    @labor_cost = LaborCost.find(params[:id])
  end

  # POST /labor_costs
  # POST /labor_costs.xml
  def create
    @labor_cost = LaborCost.new(params[:labor_cost])
    @labor_cost.task = @task

    respond_to do |format|
      if @labor_cost.save
        format.html { redirect_to([@task, @labor_cost], :notice => 'Labor cost was successfully created.') }
        format.xml  { render :xml => @labor_cost, :status => :created, :location => @labor_cost }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @labor_cost.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /labor_costs/1
  # PUT /labor_costs/1.xml
  def update
    @labor_cost = LaborCost.find(params[:id])

    respond_to do |format|
      if @labor_cost.update_attributes(params[:labor_cost])
        format.html { redirect_to([@task, @labor_cost], :notice => 'Labor cost was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @labor_cost.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /labor_costs/1
  # DELETE /labor_costs/1.xml
  def destroy
    @labor_cost = LaborCost.find(params[:id])
    @labor_cost.destroy

    respond_to do |format|
      format.html { redirect_to(task_labor_costs_url(@task)) }
      format.xml  { head :ok }
    end
  end
end
