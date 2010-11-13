class RelativeDeadlinesController < ApplicationController
  before_filter :get_deadline
  
  # GET /relative_deadlines
  # GET /relative_deadlines.xml
  def index
    @relative_deadlines = RelativeDeadline.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @relative_deadlines }
    end
  end

  # GET /relative_deadlines/1
  # GET /relative_deadlines/1.xml
  def show
    @relative_deadline = RelativeDeadline.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @relative_deadline }
    end
  end

  # GET /relative_deadlines/new
  # GET /relative_deadlines/new.xml
  def new
    @relative_deadline = RelativeDeadline.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @relative_deadline }
    end
  end

  # GET /relative_deadlines/1/edit
  def edit
    @relative_deadline = RelativeDeadline.find(params[:id])
  end

  # POST /relative_deadlines
  # POST /relative_deadlines.xml
  def create
    @relative_deadline = RelativeDeadline.new(params[:relative_deadline])
    @relative_deadline.parent_deadline = @deadline

    respond_to do |format|
      if @relative_deadline.save
        format.html { redirect_to([@deadline, @relative_deadline], :notice => 'Relative deadline was successfully created.') }
        format.xml  { render :xml => @relative_deadline, :status => :created, :location => @relative_deadline }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @relative_deadline.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /relative_deadlines/1
  # PUT /relative_deadlines/1.xml
  def update
    @relative_deadline = RelativeDeadline.find(params[:id])

    respond_to do |format|
      if @relative_deadline.update_attributes(params[:relative_deadline])
        format.html { redirect_to([@deadline, @relative_deadline], :notice => 'Relative deadline was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @relative_deadline.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /relative_deadlines/1
  # DELETE /relative_deadlines/1.xml
  def destroy
    @relative_deadline = RelativeDeadline.find(params[:id])
    @relative_deadline.destroy

    respond_to do |format|
      format.html { redirect_to(deadline_relative_deadlines_url(@deadline)) }
      format.xml  { head :ok }
    end
  end
end
