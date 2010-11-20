class MarkupsController < ApplicationController

  def add_to_project
    @parent = Project.find(params[:project_id])
    
    add_and_redirect
  end
  
  def remove_from_project
    @parent = Project.find(params[:project_id])
    
    remove_and_redirect
  end
  
  def add_to_component
    @parent = Component.find(params[:component_id])
    
    add_and_redirect
  end
  
  def remove_from_component
    @parent = Component.find(params[:component_id])
    
    remove_and_redirect
  end
  
  def add_to_task
    @parent = Task.find(params[:task_id])
    
    add_and_redirect
  end
  
  def remove_from_task
    @parent = Task.find(params[:task_id])
    
    remove_and_redirect
  end
  
  def add_to_contract
    @parent = Contract.find(params[:contract_id])
    
    add_and_redirect
  end
  
  def remove_from_contract
    @parent = Contract.find(params[:contract_id])
    
    remove_and_redirect
  end

  # GET /markups
  # GET /markups.xml
  def index
    @markups = Markup.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @markups }
    end
  end

  # GET /markups/1
  # GET /markups/1.xml
  def show
    @markup = Markup.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @markup }
    end
  end

  # GET /markups/new
  # GET /markups/new.xml
  def new
    @markup = Markup.new

    respond_to do |format|
      format.js
      format.html # new.html.erb
      format.xml  { render :xml => @markup }
    end
  end

  # GET /markups/1/edit
  def edit
    @markup = Markup.find(params[:id])
  end

  # POST /markups
  # POST /markups.xml
  def create
    @markup = Markup.new(params[:markup])

    respond_to do |format|
      if @markup.save
        format.js {
          @markups = parent.markups
        }
        format.html { redirect_to(@markup, :notice => 'Markup was successfully created.') }
        format.xml  { render :xml => @markup, :status => :created, :location => @markup }
      else
        format.js
        format.html { render :action => "new" }
        format.xml  { render :xml => @markup.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /markups/1
  # PUT /markups/1.xml
  def update
    @markup = Markup.find(params[:id])

    respond_to do |format|
      if @markup.update_attributes(params[:markup])
        format.js {
          @markups = parent.markups
        }
        format.html { redirect_to(@markup, :notice => 'Markup was successfully updated.') }
        format.xml  { head :ok }
      else
        format.js
        format.html { render :action => "edit" }
        format.xml  { render :xml => @markup.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /markups/1
  # DELETE /markups/1.xml
  def destroy
    @markup = Markup.find(params[:id])
    @markup.destroy

    respond_to do |format|
      format.html { redirect_to(markups_url) }
      format.xml  { head :ok }
    end
  end
  
  private
  
  def add_and_redirect
    @markup = Markup.find params[:id]
    @parent.markups << @markup
    
    respond_to do |format|
      format.html { redirect_to (@parent.class.name == 'Project' ? @parent : [@parent.project, @parent] ), :notice => 'Markup was successfully added.' }
    end
  end
  
  def remove_and_redirect
    @markup = Markup.find params[:id]
    @parent.markups.delete @markup
    
    respond_to do |format|
      format.html { redirect_to (@parent.class.name == 'Project' ? @parent : [@parent.project, @parent] ), :notice => 'Markup was successfully removed.' }
    end
  end
end
