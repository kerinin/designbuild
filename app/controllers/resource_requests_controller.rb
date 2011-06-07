class ResourceRequestsController < ApplicationController
  before_filter :get_project
  
  # GET /resource_requests
  # GET /resource_requests.xml
  def index
    @resource_requests = ResourceRequest.all

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
    @resource_request = ResourceRequest.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @resource_request }
    end
  end

  # GET /resource_requests/1/edit
  def edit
    @resource_request = ResourceRequest.find(params[:id])
  end

  # POST /resource_requests
  # POST /resource_requests.xml
  def create
    @resource_request = ResourceRequest.new(params[:resource_request])
    @resource_request.project = @project

    respond_to do |format|
      if @resource_request.save
        format.html { redirect_to([@project, @resource_request], :notice => 'Resource request was successfully created.') }
        format.xml  { render :xml => @resource_request, :status => :created, :location => @resource_request }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @resource_request.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /resource_requests/1
  # PUT /resource_requests/1.xml
  def update
    params[:resource_request][:resource_ids] ||= []
    @resource_request = ResourceRequest.find(params[:id])

    respond_to do |format|
      if @resource_request.update_attributes(params[:resource_request])
        format.html { redirect_to([@project, @resource_request], :notice => 'Resource request was successfully updated.') }
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
    @project = Project.find(params[:project_id])
  end
end
