class ContractsController < ApplicationController
  before_filter :get_project, :except => :add_markup
  
  def sort
    @project.contracts.all.each do |sub|
      if position = params[:contracts].index("contract_#{sub.id.to_s}")
        sub.update_attribute(:position, position + 1) unless sub.position == position + 1
      end
    end
    render :nothing => true, :status => 200
  end
  
  def add_markup
    @contract = Contract.find(params[:id])
    
    respond_to do |format|
      if @contract.markups << Markup.find(params[:markup_id])
        format.html { redirect_to([@contract.project, @contract], :notice => 'Markup was successfully added.') }
      else
        format.html { render :action => "new" }
      end
    end
  end
  
  # GET /contracts
  # GET /contracts.xml
  def index
    @contracts = @project.contracts

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @contracts }
    end
  end

  # GET /contracts/1
  # GET /contracts/1.xml
  def show
    @contract = Contract.find(params[:id])
    @inactive_markups = Markup.scoped - @contract.markups

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @contract }
    end
  end

  # GET /contracts/new
  # GET /contracts/new.xml
  def new
    @contract = Contract.new

    respond_to do |format|
      format.js
      format.html # new.html.erb
      format.xml  { render :xml => @contract }
    end
  end

  # GET /contracts/1/edit
  def edit
    @contract = Contract.find(params[:id])
  end

  # POST /contracts
  # POST /contracts.xml
  def create
    @contract = Contract.new(params[:contract])
    @contract.project = @project

    respond_to do |format|
      if @contract.save
        format.js {
          @contracts = @project.contracts
        }
        format.html { redirect_to([@project, @contract], :notice => 'Contract was successfully created.') }
        format.xml  { render :xml => @contract, :status => :created, :location => @contract }
      else
        format.js
        format.html { render :action => "new" }
        format.xml  { render :xml => @contract.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /contracts/1
  # PUT /contracts/1.xml
  def update
    @contract = Contract.find(params[:id])
    puts "CONTRACT"
    puts params[:contract]
    respond_to do |format|
      if @contract.update_attributes(params[:contract])
        format.js {
          @contracts = @project.contracts
        }
        format.html { redirect_to([@project, @contract], :notice => 'Contract was successfully updated.') }
        format.xml  { head :ok }
      else
        format.js
        format.html { render :action => "edit" }
        format.xml  { render :xml => @contract.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /contracts/1
  # DELETE /contracts/1.xml
  def destroy
    @contract = Contract.find(params[:id])
    @contract.destroy

    respond_to do |format|
      format.html { redirect_to(project_contracts_url(@project)) }
      format.xml  { head :ok }
    end
  end
end
