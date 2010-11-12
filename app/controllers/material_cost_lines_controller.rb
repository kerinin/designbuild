class MaterialCostLinesController < ApplicationController
  before_filter :get_project, :get_task
  
  # GET /material_cost_lines
  # GET /material_cost_lines.xml
  def index
    @material_cost_lines = MaterialCostLine.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @material_cost_lines }
    end
  end

  # GET /material_cost_lines/1
  # GET /material_cost_lines/1.xml
  def show
    @material_cost_line = MaterialCostLine.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @material_cost_line }
    end
  end

  # GET /material_cost_lines/new
  # GET /material_cost_lines/new.xml
  def new
    @material_cost_line = MaterialCostLine.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @material_cost_line }
    end
  end

  # GET /material_cost_lines/1/edit
  def edit
    @material_cost_line = MaterialCostLine.find(params[:id])
  end

  # POST /material_cost_lines
  # POST /material_cost_lines.xml
  def create
    @material_cost_line = MaterialCostLine.new(params[:material_cost_line])

    respond_to do |format|
      if @material_cost_line.save
        format.html { redirect_to([@project, @task, @material_cost_line], :notice => 'Material cost line was successfully created.') }
        format.xml  { render :xml => @material_cost_line, :status => :created, :location => @material_cost_line }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @material_cost_line.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /material_cost_lines/1
  # PUT /material_cost_lines/1.xml
  def update
    @material_cost_line = MaterialCostLine.find(params[:id])

    respond_to do |format|
      if @material_cost_line.update_attributes(params[:material_cost_line])
        format.html { redirect_to([@project, @task, @material_cost_line], :notice => 'Material cost line was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @material_cost_line.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /material_cost_lines/1
  # DELETE /material_cost_lines/1.xml
  def destroy
    @material_cost_line = MaterialCostLine.find(params[:id])
    @material_cost_line.destroy

    respond_to do |format|
      format.html { redirect_to(project_task_material_cost_lines_url(@project, @task)) }
      format.xml  { head :ok }
    end
  end
end
