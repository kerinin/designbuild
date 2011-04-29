class InvoiceMarkupLinesController < ApplicationController
  # GET /invoice_markup_lines
  # GET /invoice_markup_lines.xml
  def index
    @invoice_markup_lines = InvoiceMarkupLine.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @invoice_markup_lines }
    end
  end

  # GET /invoice_markup_lines/1
  # GET /invoice_markup_lines/1.xml
  def show
    @invoice_markup_line = InvoiceMarkupLine.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @invoice_markup_line }
    end
  end

  # GET /invoice_markup_lines/new
  # GET /invoice_markup_lines/new.xml
  def new
    @invoice_markup_line = InvoiceMarkupLine.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @invoice_markup_line }
    end
  end

  # GET /invoice_markup_lines/1/edit
  def edit
    @invoice_markup_line = InvoiceMarkupLine.find(params[:id])
  end

  # POST /invoice_markup_lines
  # POST /invoice_markup_lines.xml
  def create
    @invoice_markup_line = InvoiceMarkupLine.new(params[:invoice_markup_line])

    respond_to do |format|
      if @invoice_markup_line.save
        format.html { redirect_to(@invoice_markup_line, :notice => 'Invoice markup line was successfully created.') }
        format.xml  { render :xml => @invoice_markup_line, :status => :created, :location => @invoice_markup_line }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @invoice_markup_line.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /invoice_markup_lines/1
  # PUT /invoice_markup_lines/1.xml
  def update
    @invoice_markup_line = InvoiceMarkupLine.find(params[:id])

    respond_to do |format|
      if @invoice_markup_line.update_attributes(params[:invoice_markup_line])
        format.html { redirect_to(@invoice_markup_line, :notice => 'Invoice markup line was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @invoice_markup_line.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /invoice_markup_lines/1
  # DELETE /invoice_markup_lines/1.xml
  def destroy
    @invoice_markup_line = InvoiceMarkupLine.find(params[:id])
    @invoice_markup_line.destroy

    respond_to do |format|
      format.html { redirect_to(invoice_markup_lines_url) }
      format.xml  { head :ok }
    end
  end
end
