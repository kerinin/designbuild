class PaymentLinesController < ApplicationController
  # GET /payment_lines
  # GET /payment_lines.xml
  def index
    @payment_lines = PaymentLine.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @payment_lines }
    end
  end

  # GET /payment_lines/1
  # GET /payment_lines/1.xml
  def show
    @payment_line = PaymentLine.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @payment_line }
    end
  end

  # GET /payment_lines/new
  # GET /payment_lines/new.xml
  def new
    @payment_line = PaymentLine.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @payment_line }
    end
  end

  # GET /payment_lines/1/edit
  def edit
    @payment_line = PaymentLine.find(params[:id])
  end

  # POST /payment_lines
  # POST /payment_lines.xml
  def create
    @payment_line = PaymentLine.new(params[:payment_line])

    respond_to do |format|
      if @payment_line.save
        format.html { redirect_to(@payment_line, :notice => 'Payment line was successfully created.') }
        format.xml  { render :xml => @payment_line, :status => :created, :location => @payment_line }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @payment_line.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /payment_lines/1
  # PUT /payment_lines/1.xml
  def update
    @payment_line = PaymentLine.find(params[:id])

    respond_to do |format|
      if @payment_line.update_attributes(params[:payment_line])
        format.html { redirect_to(@payment_line, :notice => 'Payment line was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @payment_line.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /payment_lines/1
  # DELETE /payment_lines/1.xml
  def destroy
    @payment_line = PaymentLine.find(params[:id])
    @payment_line.destroy

    respond_to do |format|
      format.html { redirect_to(payment_lines_url) }
      format.xml  { head :ok }
    end
  end
end
