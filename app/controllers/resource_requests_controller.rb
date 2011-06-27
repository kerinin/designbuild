class ResourceRequestsController < ApplicationController
  before_filter :get_project
  
  # GET /resource_requests
  # GET /resource_requests.xml
  def index
    @resource_requests = @project.resource_requests

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @resource_requests }
    end
  end

  # GET /resource_requests/1
  # GET /resource_requests/1.xml
  def show
    @resource_request = ResourceRequest.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @resource_request }
    end
  end

  # GET /resource_requests/new
  # GET /resource_requests/new.xml
  def new
    @resource_request = ResourceRequest.new(params[:resource_request])

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @resource_request }
      format.js
    end
  end

  # GET /resource_requests/1/edit
  def edit
    @resource_request = ResourceRequest.find(params[:id])
  end

  # POST /resource_requests
  # POST /resource_requests.xml
  def create
    if params[:resource_request].has_key? :resource_allocations_attributes
       params[:resource_request][:resource_allocations_attributes].each { |key,attribute| 
          attribute.merge!({:nested => true}) unless attribute.nil?
    }
    end
    
    @resource_request = ResourceRequest.new(params[:resource_request])
    @resource_request.project = @project unless @project.nil?
    
    respond_to do |format|
      if @resource_request.save
        format.html { redirect_to(resource_resource_allocations_path(@resource_request.resource), :notice => 'Resource request was successfully created.') }
        format.xml  { render :xml => @resource_request, :status => :created, :location => @resource_request }
        format.js
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @resource_request.errors, :status => :unprocessable_entity }
        format.js
      end
    end
  end

  # PUT /resource_requests/1
  # PUT /resource_requests/1.xml
  def update
    @resource_request = ResourceRequest.find(params[:id])

    respond_to do |format|
      if @resource_request.update_attributes(params[:resource_request])
        format.html { redirect_to(resource_resource_allocations_path(@resource_request.resource), :notice => 'Resource request was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @resource_request.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /resource_requests/1
  # DELETE /resource_requests/1.xml
  def destroy
    @resource_request = ResourceRequest.find(params[:id])
    @resource_request.destroy

    respond_to do |format|
      format.html { redirect_to(project_resource_requests_url(@project)) }
      format.xml  { head :ok }
    end
  end
  
  private
  
  def get_project
    @project = Project.find(params[:project_id]) if params.has_key? :project_id
  end
end
