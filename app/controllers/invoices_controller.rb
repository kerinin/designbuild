class InvoicesController < ApplicationController
  before_filter :get_project, :except => [:start, :assign_costs, :set_amounts, :add_markups, :select_template, :finished, :accept_costs, :accept_markups]
  
  def start
    @invoice = Invoice.find(params[:id])
    @project = @invoice.project

    respond_to do |format|
      format.html
    end
  end
  
  def assign_costs
    @invoice = Invoice.find(params[:id], :include => :lines)
    @project = @invoice.project

    respond_to do |format|
      format.html {
        if ['new'].include? @invoice.state
          redirect_to start_invoice_path(@invoice)
        else
          render
        end
      }
    end    
  end
  
  def set_amounts
    @invoice = Invoice.find(params[:id], :include => :lines)
    @project = @invoice.project

    respond_to do |format|
      format.html {
        if ['new', 'payments_unbalanced'].include? @invoice.state
          redirect_to start_invoice_path(@invoice)
        elsif ['unassigned_costs'].include? @invoice.state
          redirect_to assign_costs_invoice_path(@invoice)
        else
          render
        end
      }
    end
  end
  
  def add_markups
    @invoice = Invoice.find(params[:id])
    @project = @invoice.project

    respond_to do |format|
      format.html {
        if ['new', 'payments_unbalanced'].include? @invoice.state
          redirect_to start_invoice_path(@invoice)
        elsif ['unassigned_costs'].include? @invoice.state
          redirect_to assign_costs_invoice_path(@invoice)
        elsif ['retainage_expected', 'retainage_unexpected'].include? @invoice.state
          redirect_to set_amounts_invoice_path(@invoice)
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
        if ['new', 'payments_unbalanced'].include? @invoice.state
          redirect_to start_invoice_path(@invoice)
        elsif ['unassigned_costs'].include? @invoice.state
          redirect_to assign_costs_invoice_path(@invoice)
        elsif ['retainage_expected', 'retainage_unexpected'].include? @invoice.state
          redirect_to set_amounts_invoice_path(@invoice)
        elsif ['costs_specified'].include?( @invoice.state )
          redirect_to add_markups_invoice_path(@invoice)
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
        elsif ['unassigned_costs'].include? @invoice.state
          redirect_to assign_costs_invoice_path(@invoice)
        elsif ['retainage_expected', 'retainage_unexpected'].include? @invoice.state
          redirect_to set_amounts_invoice_path(@invoice)
        elsif 'costs_specified' == @invoice.state
          redirect_to add_markups_invoice_path(@invoice)
        elsif 'markups_added' == @invoice.state
          redirect_to select_template_invoice_path(@invoice)
        else
          render
        end
      }
    end
  end
  
  def accept_costs
    @invoice = Invoice.find(params[:id])
    @project = @invoice.project
    @invoice.accept_costs
    
    respond_to do |format|
      if @invoice.save
        format.html { redirect_to( add_markups_invoice_path( @invoice ), :notice => 'Invoice was successfully updated.') }
      else
        format.html { render :action => "show" }
      end
    end
  end

  def accept_markups
    @invoice = Invoice.find(params[:id])
    @project = @invoice.project
    @invoice.accept_markups
    
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
      
      # trying to reduce update time

      if params.has_key? :update_markups
        # remove unchecked markups
        @invoice.markup_lines.each do |markup_line|
          markup_line.destroy unless params.has_key?(:included_markups) && params[:included_markups].include?( markup_line.markup_id.to_s )
        end
        
        # add checked markups
        if params.has_key? :included_markups
          params[:included_markups].each do |markup_id|
            puts "Adding Markup: #{markup_id}"
            puts @invoice.markup_line_ids
            puts @invoice.markup_line_ids.include?(markup_id.to_i)
            @invoice.markup_lines.create!(:markup_id => markup_id) unless @invoice.markup_lines.where("markup_id = ?", markup_id).exists?
          end
        end
      end
         
      #@invoice.lines.each do |line|
      #  if line.labor_retainage.nil?
      #    line.update_attributes :labor_retainage => 0
      #    line.set_default_retainage(:labor).save! 
      #  end
      #  if line.labor_retainage.nil?
      #    line.update_attributes :labor_retainage => 0
      #    line.set_default_retainage(:material).save! 
      #  end
      #end
      @invoice.advance
      @invoice.save
      
      format.html {
        case @invoice.state
        when 'new', 'payments_unbalanced'
          redirect_from_session_or start_invoice_path(@invoice)
        when 'unassigned_costs'
          redirect_from_session_or assign_costs_invoice_path(@invoice)
        when 'retainage_expected', 'retainage_unexpected'
          redirect_from_session_or set_amounts_invoice_path(@invoice)
        when 'costs_specified'
          redirect_from_session_or add_markups_invoice_path(@invoice)
        when 'markups_added'
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
      format.html { redirect_to(invoicing_project_url(@project)) }
      format.xml  { head :ok }
    end
  end
end
