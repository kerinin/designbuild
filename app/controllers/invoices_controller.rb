class InvoicesController < ApplicationController
  before_filter :get_project, :except => [:start, :set_amounts, :select_template, :finished, :accept]
  
  def start
    @invoice = Invoice.find(params[:id])
    @project = @invoice.project

    respond_to do |format|
      format.html
    end
  end
  
  def set_amounts
    @invoice = Invoice.find(params[:id])
    @project = @invoice.project

    respond_to do |format|
      format.html {
        if ['new', 'missing_task', 'payments_unbalanced'].include? @invoice.state
          redirect_to start_invoice_path(@invoice)
        else
          render
        end
      }
    end
  end
  
  def select_template
    @invoice = Invoice.find(params[:id])
    @project = @invoice.project
    @templates =Dir.entries(File.join(Rails.root, 'app', 'views', 'invoices')).map{|s| s.include?('_template_') ? 
      {:name => File.basename(s, '.html.haml').split('_template_').last.gsub('_', ' '), :path => File.basename(s, '.html.haml')[1..-1]} : 
      nil}.compact

    respond_to do |format|
      format.html {
        if ['new', 'missing_task', 'payments_unbalanced'].include? @invoice.state
          redirect_to start_invoice_path(@invoice)
        elsif ['retainage_expected', 'retainage_unexpected'].include? @invoice.state
          redirect_to set_amounts_invoice_path(@invoice)
        else
          render
        end
      }
    end
  end
  
  def finished
    @invoice = Invoice.find(params[:id])
    @project = @invoice.project

    respond_to do |format|
      format.html {
        if ['new', 'missing_task', 'payments_unbalanced'].include? @invoice.state
          redirect_to start_invoice_path(@invoice)
        elsif ['retainage_expected', 'retainage_unexpected'].include? @invoice.state
          redirect_to set_amounts_invoice_path(@invoice)
        elsif 'costs_specified' == @invoice.state
          redirect_to select_template_invoice_path(@invoice)
        else
          render
        end
      }
    end
  end
  
  def accept
    @invoice = Invoice.find(params[:id])
    @project = @invoice.project
    @invoice.accept_costs
    
    respond_to do |format|
      if @invoice.save
        format.html { redirect_to( select_template_invoice_path( @invoice ), :notice => 'Invoice was successfully updated.') }
      else
        format.html { render :action => "show" }
      end
    end
  end

  # GET /invoices
  # GET /invoices.xml
  def index
    @invoices = @project.invoices

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @invoices }
    end
  end

  # GET /invoices/1/edit
  def edit
    @invoice = Invoice.find(params[:id])
  end

  # POST /invoices
  # POST /invoices.xml
  def create
    @invoice = Invoice.new(params[:invoice])
    @invoice.project = @project

    respond_to do |format|
      if @invoice.save
        format.html { redirect_to( start_invoice_path(@invoice), :notice => 'Invoice was successfully created.') }
        format.xml  { render :xml => @invoice, :status => :created, :location => @invoice }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @invoice.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /invoices/1
  # PUT /invoices/1.xml
  def update
    @invoice = Invoice.find(params[:id])

    respond_to do |format|
      
      @invoice.attributes = params[:invoice]
      @invoice.lines.each do |line|
        if line.labor_retainage.nil?
          line.update_attributes :labor_retainage => 0
          line.set_default_retainage(:labor).save! 
        end
        if line.labor_retainage.nil?
          line.update_attributes :labor_retainage => 0
          line.set_default_retainage(:material).save! 
        end
      end
      @invoice.advance
      @invoice.save
      
      format.html {
        case @invoice.state
        when 'new', 'missing_task', 'payments_unbalanced'
          redirect_from_session_or start_invoice_path(@invoice)
        when 'retainage_expected', 'retainage_unexpected'
          redirect_from_session_or set_amounts_invoice_path(@invoice)
        when 'costs_specified'
          redirect_from_session_or select_template_invoice_path(@invoice)
        when 'complete'
          redirect_from_session_or finished_invoice_path(@invoice)
        end 
      }
    end
  end

  # DELETE /invoices/1
  # DELETE /invoices/1.xml
  def destroy
    @invoice = Invoice.find(params[:id])
    @invoice.destroy

    respond_to do |format|
      format.html { redirect_to(project_invoices_url(@project)) }
      format.xml  { head :ok }
    end
  end
end
