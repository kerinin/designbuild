class ProjectsController < ApplicationController
  autocomplete :task, :name, :full => true
  
  def invoicing
    @project = Project.find(params[:id])
    @invoices = @project.invoices
    @payments = @project.payments
    
    respond_to do |format|
      format.html
    end    
  end
  
  def timeline
    @project = Project.find(params[:id])
    
    respond_to do |format|
      format.html
    end      
  end
  
  def autocomplete_task_name
    object = :task
    method = :name
    options = {:full => true}
    
    @project = Project.find(params[:id])
    term = params[:term]

    if term && !term.empty?
      items = @project.tasks.where(["LOWER(name) LIKE ?", "%#{term.downcase}%"]).limit(10).order(:name)
    else
      items = {}
    end

    render :json => json_for_autocomplete(items, options[:display_value] ||= method)
  end

  def payroll_summary
    if params.has_key?(:id)
      @project = Project.find(params[:id])
      @labor_costs = LaborCost.by_project(@project)
    else
      @projects = Project.scoped
      @labor_costs = LaborCost.scoped
    end
    
    if params.has_key? :date
      @date = Date::new(params[:date][:year].to_i, params[:date][:month].to_i, params[:date][:day].to_i)
    else
      @date = Date::today
    end
    
    respond_to do |format|
      format.html
    end    
  end
    
  def labor_summary
    if params.has_key?(:id)
      @project = Project.find(params[:id])
      @tasks = @project.tasks
    else
      @projects = Project.scoped
      @tasks = Task.scoped
    end
    
    if params.has_key? :date
      begin
        @date = Date::new(params[:date][:year].to_i, params[:date][:month].to_i, params[:date][:day].to_i)
      rescue ArgumentError
        @date = Date::today
        flash[:alert] = "Date Error: Check that the date you entered (#{params[:date][:month]}/#{params[:date][:day]}/#{params[:date][:year]}) actually exists..."
      end
    else
      @date = Date::today
    end
    
    respond_to do |format|
      format.html
    end    
  end

  def material_cost_summary
    if params.has_key?(:id)
      @project = Project.find(params[:id])
      @tasks = @project.tasks
    else
      @projects = Project.scoped
      @tasks = Task.includes(:project) & @projects
    end
    
    if params.has_key? :date
      begin
        @date = Date::new(params[:date][:year].to_i, params[:date][:month].to_i, params[:date][:day].to_i)
      rescue ArgumentError
        @date = Date::today
        flash[:alert] = "Date Error: Check that the date you entered (#{params[:date][:month]}/#{params[:date][:day]}/#{params[:date][:year]}) actually exists..."
      end
    else
      @date = Date::today
    end
    
    respond_to do |format|
      format.html
    end    
  end
    
  def purchase_order_list
    if params.has_key?(:id)
      @projects = [Project.find(params[:id])]
    else
      @projects = Project.all
    end
    @suppliers = Supplier.all
    
    respond_to do |format|
      format.html
    end
  end
  
  def add_markup
    @project = Project.find(params[:id])
    
    respond_to do |format|
      if @project.markups << Markup.find(params[:markup_id])
        format.html { redirect_to(@project, :notice => 'Markup was successfully added.') }
      else
        format.html { render :action => "new" }
      end
    end
  end
  
  def estimate_report
    @project = Project.find(params[:id])
    session[:break_out_unit_costs] = (1 == params[:break_out_unit_costs].to_i) if params.has_key?(:break_out_unit_costs)
    session[:break_out_markup] = (1 == params[:break_out_markup].to_i) if params.has_key?(:break_out_markup)
    session[:show_graph] = (1 == params[:show_graph].to_i) if params.has_key?(:show_graph)

    respond_to do |format|
      format.html # show.html.erb
    end  
  end

  def cost_report
    @project = Project.find(params[:id])
    session[:break_out_costs] = (1 == params[:break_out_costs].to_i) if params.has_key?(:break_out_costs)

    respond_to do |format|
      format.html # show.html.erb
    end  
  end
    
  # GET /projects
  # GET /projects.xml
  def index
    @projects = Project.order( :name ).all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @projects }
    end
  end

  # GET /projects/1
  # GET /projects/1.xml
  def show
    @project = Project.find(params[:id])
    @inactive_markups = Markup.scoped - @project.markups

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @project }
    end
  end

  # GET /projects/new
  # GET /projects/new.xml
  def new
    @project = Project.new

    respond_to do |format|
      format.js
      format.html # new.html.erb
      format.xml  { render :xml => @project }
    end
  end

  # GET /projects/1/edit
  def edit
    @project = Project.find(params[:id])
  end

  # POST /projects
  # POST /projects.xml
  def create
    @project = Project.new(params[:project])

    respond_to do |format|
      if @project.save
        format.js {
          @projects = Project.order( :name ).all
        }
        format.html { redirect_to(@project, :notice => 'Project was successfully created.') }
        format.xml  { render :xml => @project, :status => :created, :location => @project }
      else
        format.js
        format.html { render :action => "new" }
        format.xml  { render :xml => @project.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /projects/1
  # PUT /projects/1.xml
  def update
    @project = Project.find(params[:id])

    respond_to do |format|
      if @project.update_attributes(params[:project])
        format.js {
          @projects = Project.order( :name ).all
        }
        format.html { redirect_from_session_or(@project, :notice => 'Project was successfully updated.') }
        format.xml  { head :ok }
      else
        format.js
        format.html { render :action => "edit" }
        format.xml  { render :xml => @project.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /projects/1
  # DELETE /projects/1.xml
  def destroy
    @project = Project.find(params[:id])
    @project.destroy

    respond_to do |format|
      format.html { redirect_to(projects_url) }
      format.xml  { head :ok }
    end
  end
end
