class ContractCostsController < ApplicationController
  before_filter :get_contract
  
  # GET /contract_costs
  # GET /contract_costs.xml
  def index
    @contract_costs = ContractCost.all
    @inactive_markups = Markup.scoped - @contract.markups

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @contract_costs }
    end
  end

  # GET /contract_costs/1
  # GET /contract_costs/1.xml
  def show
    @contract_cost = ContractCost.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @contract_cost }
    end
  end

  # GET /contract_costs/new
  # GET /contract_costs/new.xml
  def new
    @contract_cost = ContractCost.new

    respond_to do |format|
      format.js
      format.html # new.html.erb
      format.xml  { render :xml => @contract_cost }
    end
  end

  # GET /contract_costs/1/edit
  def edit
    @contract_cost = ContractCost.find(params[:id])
  end

  # POST /contract_costs
  # POST /contract_costs.xml
  def create
    @contract_cost = ContractCost.new(params[:contract_cost])
    @contract_cost.contract = @contract
    
    respond_to do |format|
      if @contract_cost.save
        format.js {
          @inactive_markups = Markup.scoped - @contract.markups
          @contract_costs = @contract.costs
        }
        format.html { redirect_to(contract_contract_cost_path(@contract, @contract_cost), :notice => 'Contract cost was successfully created.') }
        format.xml  { render :xml => @contract_cost, :status => :created, :location => @contract_cost }
      else
        format.js
        format.html { render :action => "new" }
        format.xml  { render :xml => @contract_cost.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /contract_costs/1
  # PUT /contract_costs/1.xml
  def update
    @contract_cost = ContractCost.find(params[:id])

    respond_to do |format|
      if @contract_cost.update_attributes(params[:contract_cost])
        format.js {
          @inactive_markups = Markup.scoped - @contract.markups
          @contract_costs = @contract.costs
        }
        format.html { redirect_to(contract_contract_cost_path(@contract, @contract_cost), :notice => 'Contract cost was successfully updated.') }
        format.xml  { head :ok }
      else
        format.js
        format.html { render :action => "edit" }
        format.xml  { render :xml => @contract_cost.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /contract_costs/1
  # DELETE /contract_costs/1.xml
  def destroy
    @contract_cost = ContractCost.find(params[:id])
    @contract_cost.destroy

    respond_to do |format|
      format.html { redirect_to(project_contract_url(@project, @contract)) }
      format.xml  { head :ok }
    end
  end
end
