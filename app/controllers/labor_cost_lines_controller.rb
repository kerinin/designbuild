class LaborCostLinesController < ApplicationController
  before_filter :get_labor_set
  
  # GET /labor_cost_lines
  # GET /labor_cost_lines.xml
  def index
    @labor_cost_lines = LaborCostLine.scoped

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @labor_cost_lines }
    end
  end

  # GET /labor_cost_lines/1
  # GET /labor_cost_lines/1.xml
  def show
    @labor_cost_line = LaborCostLine.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @labor_cost_line }
    end
  end

  # GET /labor_cost_lines/new
  # GET /labor_cost_lines/new.xml
  def new
    @labor_cost_line = LaborCostLine.new
    @laborers = Laborer.scoped - @labor_cost.line_items.all.map{|li| li.laborer}

    respond_to do |format|
      format.js
      format.html # new.html.erb
      format.xml  { render :xml => @labor_cost_line }
    end
  end

  # GET /labor_cost_lines/1/edit
  def edit
    @labor_cost_line = LaborCostLine.find(params[:id])
    @laborers = Laborer.scoped
  end

  # POST /labor_cost_lines
  # POST /labor_cost_lines.xml
  def create
    @labor_cost_line = LaborCostLine.new(params[:labor_cost_line])
    @labor_cost_line.labor_set = @labor_cost
    @laborers = Laborer.scoped

    respond_to do |format|
      if @labor_cost_line.save
        format.js {
          @labor_cost_lines = @labor_cost.line_items
        }
        format.html { redirect_to(labor_cost_line_item_path(@labor_cost, @labor_cost_line), :notice => 'Labor cost line was successfully created.') }
        format.xml  { render :xml => @labor_cost_line, :status => :created, :location => @labor_cost_line }
      else
        format.js
        format.html { render :action => "new" }
        format.xml  { render :xml => @labor_cost_line.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /labor_cost_lines/1
  # PUT /labor_cost_lines/1.xml
  def update
    @labor_cost_line = LaborCostLine.find(params[:id])

    respond_to do |format|
      if @labor_cost_line.update_attributes(params[:labor_cost_line])
        format.js
        format.html { redirect_to(labor_cost_line_item_path(@labor_cost, @labor_cost_line), :notice => 'Labor cost line was successfully updated.') }
        format.xml  { head :ok }
      else
        format.js
        format.html { render :action => "edit" }
        format.xml  { render :xml => @labor_cost_line.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /labor_cost_lines/1
  # DELETE /labor_cost_lines/1.xml
  def destroy
    @labor_cost_line = LaborCostLine.find(params[:id])
    @labor_cost_line.destroy
    @labor_cost.reload
    
    respond_to do |format|
      format.html { redirect_to(task_labor_cost_url(@task, @labor_cost)) }
      format.xml  { head :ok }
      format.js
    end
  end
end
