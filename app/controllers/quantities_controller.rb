class QuantitiesController < ApplicationController
  before_filter :get_component
  
  # GET /quantities
  # GET /quantities.xml
  def index
    @quantities = Quantity.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @quantities }
    end
  end

  # GET /quantities/1
  # GET /quantities/1.xml
  def show
    @quantity = Quantity.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @quantity }
    end
  end

  # GET /quantities/new
  # GET /quantities/new.xml
  def new
    @quantity = Quantity.new :component => @component

    respond_to do |format|
      format.js
      format.html # new.html.erb
      format.xml  { render :xml => @quantity }
    end
  end

  # GET /quantities/1/edit
  def edit
    @quantity = Quantity.find(params[:id])
  end

  # POST /quantities
  # POST /quantities.xml
  def create
    @quantity = Quantity.new(params[:quantity])
    @quantity.component = @component

    respond_to do |format|
      if @quantity.save
        format.js { 
          @quantities = @component.quantities
        }
        format.html { redirect_to([@component, @quantity], :notice => 'Quantity was successfully created.') }
        format.xml  { render :xml => @quantity, :status => :created, :location => @quantity }
      else
        format.js
        format.html { render :action => "new" }
        format.xml  { render :xml => @quantity.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /quantities/1
  # PUT /quantities/1.xml
  def update
    @quantity = Quantity.find(params[:id])

    respond_to do |format|
      if @quantity.update_attributes(params[:quantity])
        format.js { render :nothing => true }
        format.html { redirect_to([@project,@component], :notice => 'Quantity was successfully updated.') }
        format.xml  { head :ok }
      else
        format.js
        format.html { render :action => "edit" }
        format.xml  { render :xml => @quantity.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /quantities/1
  # DELETE /quantities/1.xml
  def destroy
    @quantity = Quantity.find(params[:id])
    @quantity.destroy

    respond_to do |format|
      format.html { redirect_to(component_quantities_url(@component)) }
      format.xml  { head :ok }
    end
  end
end
