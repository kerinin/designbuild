class BidsController < ApplicationController
  before_filter :get_contract
  
  # GET /bids
  # GET /bids.xml
  def index
    @bids = @contract.bids

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @bids }
    end
  end

  # GET /bids/1
  # GET /bids/1.xml
  def show
    @bid = Bid.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @bid }
    end
  end

  # GET /bids/new
  # GET /bids/new.xml
  def new
    @bid = Bid.new

    respond_to do |format|
      format.js
      format.html # new.html.erb
      format.xml  { render :xml => @bid }
    end
  end

  # GET /bids/1/edit
  def edit
    @bid = Bid.find(params[:id])
  end

  # POST /bids
  # POST /bids.xml
  def create
    @bid = Bid.new(params[:bid])
    @bid.contract = @contract

    respond_to do |format|
      if @bid.save
        format.js {
          @bids = @contract.bids
        }
        format.html { redirect_to( [@contract, @bid], :notice => 'Bid was successfully created.') }
        format.xml  { render :xml => @bid, :status => :created, :location => @bid }
      else
        format.js
        format.html { render :action => "new" }
        format.xml  { render :xml => @bid.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /bids/1
  # PUT /bids/1.xml
  def update
    @bid = Bid.find(params[:id])

    respond_to do |format|
      if @bid.update_attributes(params[:bid])
        format.js {
          @bids = @contract.bids
        }
        format.html { redirect_to([@contract, @bid], :notice => 'Bid was successfully updated.') }
        format.xml  { head :ok }
      else
        format.js
        format.html { render :action => "edit" }
        format.xml  { render :xml => @bid.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /bids/1
  # DELETE /bids/1.xml
  def destroy
    @bid = Bid.find(params[:id])
    @bid.destroy

    respond_to do |format|
      format.html { redirect_to(project_contract_url(@project, @contract)) }
      format.xml  { head :ok }
    end
  end
end
