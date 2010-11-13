class DerivedQuantitiesController < ApplicationController
  before_filter :get_project, :get_component
  
  # GET /derived_quantities
  # GET /derived_quantities.xml
  def index
    @derived_quantities = DerivedQuantity.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @derived_quantities }
    end
  end

  # GET /derived_quantities/1
  # GET /derived_quantities/1.xml
  def show
    @derived_quantity = DerivedQuantity.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @derived_quantity }
    end
  end

  # GET /derived_quantities/new
  # GET /derived_quantities/new.xml
  def new
    @derived_quantity = DerivedQuantity.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @derived_quantity }
    end
  end

  # GET /derived_quantities/1/edit
  def edit
    @derived_quantity = DerivedQuantity.find(params[:id])
  end

  # POST /derived_quantities
  # POST /derived_quantities.xml
  def create
    @derived_quantity = DerivedQuantity.new(params[:derived_quantity])
    @derived_quantity.component = @component

    respond_to do |format|
      if @derived_quantity.save
        format.html { redirect_to([@project, @component, @derived_quantity], :notice => 'Derived quantity was successfully created.') }
        format.xml  { render :xml => @derived_quantity, :status => :created, :location => @derived_quantity }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @derived_quantity.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /derived_quantities/1
  # PUT /derived_quantities/1.xml
  def update
    @derived_quantity = DerivedQuantity.find(params[:id])

    respond_to do |format|
      if @derived_quantity.update_attributes(params[:derived_quantity])
        format.html { redirect_to([@project, @component, @derived_quantity], :notice => 'Derived quantity was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @derived_quantity.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /derived_quantities/1
  # DELETE /derived_quantities/1.xml
  def destroy
    @derived_quantity = DerivedQuantity.find(params[:id])
    @derived_quantity.destroy

    respond_to do |format|
      format.html { redirect_to(project_component_derived_quantities_url(@project, @component)) }
      format.xml  { head :ok }
    end
  end
end
