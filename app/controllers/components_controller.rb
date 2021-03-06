class ComponentsController < ApplicationController
  before_filter :get_objects
  #before_filter :get_project, :except => :add_markup
  
  def sort
    if params.has_key?(:id)
      set = Component.find(params[:id]).children.all
    else
      set = @project.components.roots.all
    end
    
    set.each do |sub|
      if position = params[:components].index("component_#{sub.id.to_s}")
        sub.update_attribute(:position, position + 1) unless sub.position == position + 1
      end
    end
    render :nothing => true, :status => 200
  end
  
  def changelog
    @component = Component.find(params[:id])
    
    respond_to do |format|
      format.html
    end
  end
  
  def add_markup
    @component = Component.find(params[:id])
    
    respond_to do |format|
      if @component.markups << Markup.find(params[:markup_id])
        format.html { redirect_to([@component.project, @component], :notice => 'Markup was successfully added.') }
      else
        format.html { render :action => "new" }
      end
    end
  end
  
  # GET /components
  # GET /components.xml
  def index
    @components ||= @project.components.roots

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @components }
    end
  end

  # GET /components/1
  # GET /components/1.xml
  def show
    @component = Component.find(params[:id])
    @inactive_markups = Markup.scoped - @component.markups
    
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
      format.js {
        @context_component = Component.find(params[:context]) if params.has_key?(:context)
      }
      format.html # new.html.erb
      format.xml  { render :xml => @component }
    end
  end

  # GET /components/new
  # GET /components/new.xml
  def new_cost
    @component = Component.find(params[:id])

    respond_to do |format|
      format.js {
        @context_component = Component.find(params[:context]) if params.has_key?(:context)
      }
      format.html # new.html.erb
      format.xml  { render :xml => @component }
    end
  end
  
  # GET /components/1/edit
  def edit
    @component = Component.find(params[:id])
    
    respond_to do |format|
      format.js {
        @context_component = Component.find(params[:context]) if params.has_key?(:context)
      }
      format.html
    end
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
          @context_component = Component.find(params[:context]) if params.has_key?(:context)
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
          @context_component = Component.find(params[:context]) if params.has_key?(:context)
        }
        format.html { 
          if params.has_key? :redirect
            redirect_to(params[:redirect])
          else
            redirect_to(@component, :notice => 'Component was successfully updated.') 
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
        if params.has_key? :redirect
          redirect_to(params[:redirect])
        elsif @parent.nil?
          redirect_to(project_components_url(@project)) 
        else
          redirect_to(project_component_url(@project, @parent)) 
        end
      }
      format.xml  { head :ok }
    end
  end
  
  private
  
  def get_objects
    @component = Component.find(params[:id]) if params.has_key? :id
    @project = Project.find(params[:project_id]) if params.has_key? :project_id
    @parent_component = Component.find(params[:component_id]) if params.has_key? :component_id
    
    @project ||= @component.project unless @component.nil?
    @project ||= @parent_component.project unless @parent_component.nil?
    @components = @parent_component.children unless @parent_component.nil?
  end
end
