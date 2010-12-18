class PaymentsController < ApplicationController
  before_filter :get_project, :except => [:start, :balance, :finished, :accept]
  
  def start
    @payment = Payment.find(params[:id])
    @project = @payment.project

    respond_to do |format|
      format.html
    end
  end
  
  def balance
    @payment = Payment.find(params[:id])
    @project = @payment.project

    respond_to do |format|
      format.html {
        if ['new', 'missing_task'].include? @payment.state
          redirect_to start_payment_path(@payment)
        else
          render
        end
      }
    end
  end
  
  def finished
    @payment = Payment.find(params[:id])
    @project = @payment.project

    respond_to do |format|
      format.html {
        if ['new', 'missing_task'].include? @payment.state
          redirect_to start_payment_path(@invoice)
        elsif ['balanced', 'unbalanced'].include? @payment.state
          redirect_to balance_payment_path(@payment)
        else
          render
        end
      }
    end
  end
  
  def accept
    @payment = Payment.find(params[:id])
    @project = @payment.project
    @payment.accept_payment
    
    respond_to do |format|
      if @payment.save
        format.html { 
          if @payment.state == 'complete'
            redirect_to( finished_payment_path( @payment ), :notice => 'Payment was successfully updated.') 
          else
            redirect_to( balance_payment_path( @payment ), :notice => 'Payment must be balanced first' )
          end
        }
      else
        format.html {  redirect_to balance_payment_path(@payment) }
      end
    end
  end

  
  # GET /payments
  # GET /payments.xml
  def index
    @payments = Payment.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @payments }
    end
  end
  
=begin
  # GET /payments/1
  # GET /payments/1.xml
  def show
    @payment = Payment.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @payment }
    end
  end


  # GET /payments/new
  # GET /payments/new.xml
  def new
    @payment = Payment.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @payment }
    end
  end
=end

  # GET /payments/1/edit
  def edit
    @payment = Payment.find(params[:id])
  end

  # POST /payments
  # POST /payments.xml
  def create
    @payment = Payment.new(params[:payment])
    @payment.project = @project

    respond_to do |format|
      if @payment.save
        format.html { redirect_to( start_payment_path(@payment), :notice => 'Payment was successfully created.') }
        format.xml  { render :xml => @payment, :status => :created, :location => @payment }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @payment.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /payments/1
  # PUT /payments/1.xml
  def update
    @payment = Payment.find(params[:id])

    respond_to do |format|
      @payment.update_attributes(params[:payment])
      format.html {
        case @payment.state
        when 'new', 'missing_task'
          redirect_from_session_or start_payment_path(@payment)
        when 'balanced', 'unbalanced'
          redirect_from_session_or balance_payment_path(@payment)
        when 'complete'
          redirect_from_session_or finished_payment_path(@payment)
        end 
      }
    end
  end

  # DELETE /payments/1
  # DELETE /payments/1.xml
  def destroy
    @payment = Payment.find(params[:id])
    @payment.destroy

    respond_to do |format|
      format.html { redirect_to(project_payments_url(@project)) }
      format.xml  { head :ok }
    end
  end
end
