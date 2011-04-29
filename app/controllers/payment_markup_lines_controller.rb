class PaymentMarkupLinesController < ApplicationController
  # GET /payment_markup_lines
  # GET /payment_markup_lines.xml
  def index
    @payment_markup_lines = PaymentMarkupLine.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @payment_markup_lines }
    end
  end

  # GET /payment_markup_lines/1
  # GET /payment_markup_lines/1.xml
  def show
    @payment_markup_line = PaymentMarkupLine.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @payment_markup_line }
    end
  end

  # GET /payment_markup_lines/new
  # GET /payment_markup_lines/new.xml
  def new
    @payment_markup_line = PaymentMarkupLine.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @payment_markup_line }
    end
  end

  # GET /payment_markup_lines/1/edit
  def edit
    @payment_markup_line = PaymentMarkupLine.find(params[:id])
  end

  # POST /payment_markup_lines
  # POST /payment_markup_lines.xml
  def create
    @payment_markup_line = PaymentMarkupLine.new(params[:payment_markup_line])

    respond_to do |format|
      if @payment_markup_line.save
        format.html { redirect_to(@payment_markup_line, :notice => 'Payment markup line was successfully created.') }
        format.xml  { render :xml => @payment_markup_line, :status => :created, :location => @payment_markup_line }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @payment_markup_line.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /payment_markup_lines/1
  # PUT /payment_markup_lines/1.xml
  def update
    @payment_markup_line = PaymentMarkupLine.find(params[:id])

    respond_to do |format|
      if @payment_markup_line.update_attributes(params[:payment_markup_line])
        format.html { redirect_to(@payment_markup_line, :notice => 'Payment markup line was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @payment_markup_line.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /payment_markup_lines/1
  # DELETE /payment_markup_lines/1.xml
  def destroy
    @payment_markup_line = PaymentMarkupLine.find(params[:id])
    @payment_markup_line.destroy

    respond_to do |format|
      format.html { redirect_to(payment_markup_lines_url) }
      format.xml  { head :ok }
    end
  end
end
