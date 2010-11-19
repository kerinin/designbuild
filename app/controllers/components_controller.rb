class ComponentsController < ApplicationController
  before_filter :get_project
  
  # GET /components
  # GET /components.xml
  def index
    @components = @project.components.roots

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @components }
    end
  end

  # GET /components/1
  # GET /components/1.xml
  def show
    @component = Component.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @component }
    end
  end

  # GET /components/new
  # GET /components/new.xml
  def new
    @parent_component = params.has_key?( :parent_id ) ? Component.find( params[:parent_id] ) : nil
    @component = Component.new :parent => @parent_component

    respond_to do |format|
      format.js 
      format.html # new.html.erb
      format.xml  { render :xml => @component }
    end
  end

  # GET /components/1/edit
  def edit
    @component = Component.find(params[:id])
  end

  # POST /components
  # POST /components.xml
  def create
    @parent_component = params[:component].has_key?( :parent_id ) ? Component.find( params[:component][:parent_id] ) : nil
    @component = Component.new(params[:component])
    @component.project = @project
    @component.parent = @parent_component unless @parent_component.nil?

    respond_to do |format|
      if @component.save
        format.js { 
          @components = @component.is_root? ? @project.components.roots : @component.siblings
        }
        format.html { redirect_to([@project, @component], :notice => 'Component was successfully created.') }
        format.xml  { render :xml => @component, :status => :created, :location => @component }
      else
        format.js
        format.html { render :action => "new" }
        format.xml  { render :xml => @component.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /components/1
  # PUT /components/1.xml
  def update
    @component = Component.find(params[:id])

    respond_to do |format|
      if @component.update_attributes(params[:component])
        format.js { 
          @components = @component.is_root? ? @project.components.roots : @component.siblings
        }
        format.html { 
          if params.has_key? :redirect
            redirect_to(params[:redirect])
          else
            redirect_to([@project, @component], :notice => 'Component was successfully updated.') 
          end
        }
        format.xml  { head :ok }
      else
        format.js
        format.html { render :action => "edit" }
        format.xml  { render :xml => @component.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /components/1
  # DELETE /components/1.xml
  def destroy
    @component = Component.find(params[:id])
    @parent = @component.parent
    @component.destroy

    respond_to do |format|
      format.html { 
        if @parent.nil?
          redirect_to(project_components_url(@project)) 
        else
          redirect_to(project_component_url(@project, @parent)) 
        end
      }
      format.xml  { head :ok }
    end
  end
end
