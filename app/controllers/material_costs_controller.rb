class MaterialCostsController < ApplicationController
  # GET /material_costs
  # GET /material_costs.xml
  def index
    @material_costs = MaterialCost.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @material_costs }
    end
  end

  # GET /material_costs/1
  # GET /material_costs/1.xml
  def show
    @material_cost = MaterialCost.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @material_cost }
    end
  end

  # GET /material_costs/new
  # GET /material_costs/new.xml
  def new
    @material_cost = MaterialCost.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @material_cost }
    end
  end

  # GET /material_costs/1/edit
  def edit
    @material_cost = MaterialCost.find(params[:id])
  end

  # POST /material_costs
  # POST /material_costs.xml
  def create
    @material_cost = MaterialCost.new(params[:material_cost])

    respond_to do |format|
      if @material_cost.save
        format.html { redirect_to(@material_cost, :notice => 'Material cost was successfully created.') }
        format.xml  { render :xml => @material_cost, :status => :created, :location => @material_cost }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @material_cost.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /material_costs/1
  # PUT /material_costs/1.xml
  def update
    @material_cost = MaterialCost.find(params[:id])

    respond_to do |format|
      if @material_cost.update_attributes(params[:material_cost])
        format.html { redirect_to(@material_cost, :notice => 'Material cost was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @material_cost.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /material_costs/1
  # DELETE /material_costs/1.xml
  def destroy
    @material_cost = MaterialCost.find(params[:id])
    @material_cost.destroy

    respond_to do |format|
      format.html { redirect_to(material_costs_url) }
      format.xml  { head :ok }
    end
  end
end