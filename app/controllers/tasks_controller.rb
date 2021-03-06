class TasksController < ApplicationController
  #before_filter :get_project, :except => :add_markup
  before_filter :get_objects
  
  def add_markup
    @task = Task.find(params[:id])
    
    respond_to do |format|
      if @task.markups << Markup.find(params[:markup_id])
        format.html { redirect_to([@task.project, @task], :notice => 'Markup was successfully added.') }
      else
        format.html { render :action => "new" }
      end
    end
  end
  
  # GET /tasks
  # GET /tasks.xml
  def index
    @tasks = @project.tasks

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @tasks }
    end
  end
  
  def scheduling
    @task = Task.find(params[:id])
    @inactive_markups = Markup.scoped - @task.markups
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @task }
    end
  end
  
  def estimated_costs
    @task = Task.find(params[:id])
    @inactive_markups = Markup.scoped - @task.markups
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @task }
    end
  end
  
  def costs
    @task = Task.find(params[:id])
    @inactive_markups = Markup.scoped - @task.markups
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @task }
    end
  end
  
  # GET /tasks/1
  # GET /tasks/1.xml
  def show
    @task = Task.find(params[:id])
    @inactive_markups = Markup.scoped - @task.markups
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @task }
    end
  end

  # GET /tasks/new
  # GET /tasks/new.xml
  def new
    @task = Task.new

    respond_to do |format|
      format.js
      format.html # new.html.erb
      format.xml  { render :xml => @task }
    end
  end

  # GET /tasks/1/edit
  def edit
    @task = Task.find(params[:id])
  end

  # POST /tasks
  # POST /tasks.xml
  def create
    @task = Task.new(params[:task])
    @task.project = @project

    respond_to do |format|
      if @task.save
        format.js { 
          @tasks = @project.tasks
        }
        format.html { redirect_to([@project, @task], :notice => 'Task was successfully created.') }
        format.xml  { render :xml => @task, :status => :created, :location => @task }
      else
        format.js
        format.html { render :action => "new" }
        format.xml  { render :xml => @task.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /tasks/1
  # PUT /tasks/1.xml
  def update
    @task = Task.find(params[:id])

    respond_to do |format|
      if @task.update_attributes(params[:task])
        format.js { 
          if params[:render_nothing]
            render :nothing => true
          else
            @tasks = @project.tasks
          end
        }
        format.html { redirect_from_session_or([@project, @task], :notice => 'Task was successfully updated.') }
        format.xml  { head :ok }
      else
        format.js
        format.html { render :action => "edit" }
        format.xml  { render :xml => @task.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /tasks/1
  # DELETE /tasks/1.xml
  def destroy
    @task = Task.find(params[:id])
    @task.destroy

    respond_to do |format|
      format.html { redirect_to(project_tasks_url(@project)) }
      format.xml  { head :ok }
    end
  end
  
  protected
  
  def get_objects
    @task = Task.find(params[:id]) if params.has_key? :id
    @project = Project.find(params[:project_id]) if params.has_key? :project_id
    
    @project ||= @task.project unless @task.nil?
  end
end
