class ReportsController < ApplicationController
  def index
    @projects = Project.scoped
    @laborers = Laborer.scoped
    @material_costs = MaterialCost.scoped
    @labor_costs = LaborCost.scoped
     
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @quantities }
    end
  end
end
