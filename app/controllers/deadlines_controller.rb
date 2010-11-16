class DeadlinesController < ApplicationController
  before_filter :get_project
  
  # GET /deadlines
  # GET /deadlines.xml
  def index
    @deadlines = @project.deadlines

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @deadlines }
    end
  end

  # GET /deadlines/1
  # GET /deadlines/1.xml
  def show
    @deadline = Deadline.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @deadline }
    end
  end

  # GET /deadlines/new
  # GET /deadlines/new.xml
  def new
    @deadline = Deadline.new

    respond_to do |format|
      format.js
      format.html # new.html.erb
      format.xml  { render :xml => @deadline }
    end
  end

  # GET /deadlines/1/edit
  def edit
    @deadline = Deadline.find(params[:id])
  end

  # POST /deadlines
  # POST /deadlines.xml
  def create
    @deadline = Deadline.new(params[:deadline])
    @deadline.project = @project

    respond_to do |format|
      if @deadline.save
        format.js { 
          @deadlines = @project.deadlines
        }
        format.html { redirect_to([@project, @deadline], :notice => 'Deadline was successfully created.') }
        format.xml  { render :xml => @deadline, :status => :created, :location => @deadline }
      else
        format.js
        format.html { render :action => "new" }
        format.xml  { render :xml => @deadline.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /deadlines/1
  # PUT /deadlines/1.xml
  def update
    @deadline = Deadline.find(params[:id])

    respond_to do |format|
      if @deadline.update_attributes(params[:deadline])
        format.js { 
          @deadlines = @project.deadlines
        }
        format.html { redirect_to([@project, @deadline], :notice => 'Deadline was successfully updated.') }
        format.xml  { head :ok }
      else
        format.js
        format.html { render :action => "edit" }
        format.xml  { render :xml => @deadline.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /deadlines/1
  # DELETE /deadlines/1.xml
  def destroy
    @deadline = Deadline.find(params[:id])
    @deadline.destroy

    respond_to do |format|
      format.html { redirect_to(project_deadlines_url(@project)) }
      format.xml  { head :ok }
    end
  end
end
