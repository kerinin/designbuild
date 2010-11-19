class MarkupsController < ApplicationController
  inherit_resources
  
  #belongs_to :parent, :polymorphic => true
  polymorphic_belongs_to :project, :contract, :component, :task, :parent
  
  respond_to :js #, :only => [:new, :create, :edit, :update]
  
  def create
    create! do |success,failure|
      success.js { @markups = parent.markups }
    end
  end

  def update
    update! do |success,failure|
      success.js { @markups = parent.markups }
    end
  end     
  
  def destroy
    destroy! { parent_path( :project_id => parent.class.name != 'Project' ? parent.project.id : nil ) }
  end
  
=begin  
  # GET /markups
  # GET /markups.xml
  def index
    @parent_object = parent
    @markups = Markup.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @markups }
    end
  end

  # GET /markups/1
  # GET /markups/1.xml
  def show
    @parent_object = parent
    @markup = Markup.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @markup }
    end
  end

  # GET /markups/new
  # GET /markups/new.xml
  def new
    @parent_object = parent
    @markup = Markup.new

    respond_to do |format|
      format.js
      format.html # new.html.erb
      format.xml  { render :xml => @markup }
    end
  end

  # GET /markups/1/edit
  def edit
    @parent_object = parent
    @markup = Markup.find(params[:id])
  end

  # POST /markups
  # POST /markups.xml
  def create
    @parent_object = parent
    @markup = Markup.new(params[:markup])

    respond_to do |format|
      if @markup.save
        format.js {
          @markups = parent.markups
        }
        format.html { redirect_to([parent, @markup], :notice => 'Markup was successfully created.') }
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
    @parent_object = parent
    @markup = Markup.find(params[:id])

    respond_to do |format|
      if @markup.update_attributes(params[:markup])
        format.js {
          @markups = parent.markups
        }
        format.html { redirect_to([parent, @markup], :notice => 'Markup was successfully updated.') }
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
    @parent_object = parent
    @markup = Markup.find(params[:id])
    @markup.destroy

    respond_to do |format|
      format.html { redirect_to(parent) }
      format.xml  { head :ok }
    end
  end
=end
end
