class LaborersController < ApplicationController
  before_filter :get_project
  
  # GET /laborers
  # GET /laborers.xml
  def index
    @laborers = Laborer.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @laborers }
    end
  end

  # GET /laborers/1
  # GET /laborers/1.xml
  def show
    @laborer = Laborer.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @laborer }
    end
  end

  # GET /laborers/new
  # GET /laborers/new.xml
  def new
    @laborer = Laborer.new

    respond_to do |format|
      format.js
      format.html # new.html.erb
      format.xml  { render :xml => @laborer }
    end
  end

  # GET /laborers/1/edit
  def edit
    @laborer = Laborer.find(params[:id])
  end

  # POST /laborers
  # POST /laborers.xml
  def create
    @laborer = Laborer.new(params[:laborer])
    @laborer.project = @project

    respond_to do |format|
      if @laborer.save
        format.js
        format.html { redirect_to([@project, @laborer], :notice => 'Laborer was successfully created.') }
        format.xml  { render :xml => @laborer, :status => :created, :location => @laborer }
      else
        format.js
        format.html { render :action => "new" }
        format.xml  { render :xml => @laborer.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /laborers/1
  # PUT /laborers/1.xml
  def update
    @laborer = Laborer.find(params[:id])

    respond_to do |format|
      if @laborer.update_attributes(params[:laborer])
        format.html { redirect_to([@project, @laborer], :notice => 'Laborer was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @laborer.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /laborers/1
  # DELETE /laborers/1.xml
  def destroy
    @laborer = Laborer.find(params[:id])
    @laborer.destroy

    respond_to do |format|
      format.html { redirect_to(project_laborers_url(@project)) }
      format.xml  { head :ok }
    end
  end
end
