require File.dirname(__FILE__) + '/../test_helper'

class InvoiceableTest < ActiveSupport::TestCase
  context "Given a project" do
    setup do
      @project = Factory :project
      @component1 = Factory :component, :project => @project
      @task1 = Factory :task, :project => @project
      @component2 = Factory :component, :project => @project
      @task2 = Factory :task, :project => @project
      
      @l = Factory :laborer, :bill_rate => 1
      @lc = Factory :labor_cost, :task => @task1, :percent_complete => 50
      @lcl = Factory :labor_cost_line, :laborer => @l, :hours => 40, :labor_set => @lc
      @mc = Factory :material_cost, :task => @task2, :raw_cost => 60
      
      @fce1 = Factory :fixed_cost_estimate, :component => @component1, :task => @task1, :raw_cost => 1
      @fce2 = Factory :fixed_cost_estimate, :component => @component1, :raw_cost => 10
      @fce3 = Factory :fixed_cost_estimate, :component => @component2, :task => @task2, :raw_cost => 100
      @fce4 = Factory :fixed_cost_estimate, :component => @component1, :raw_cost => 1000
      
      @q = Factory :quantity, :component => @component1, :value => 2
      @uce1 = Factory :unit_cost_estimate, :component => @component1, :task => @task1, :unit_cost => 1, :quantity => @q
      @uce2 = Factory :unit_cost_estimate, :component => @component1, :unit_cost => 10, :quantity => @q
      @uce3 = Factory :unit_cost_estimate, :component => @component2, :task => @task2, :unit_cost => 100, :quantity => @q
      @uce4 = Factory :unit_cost_estimate, :component => @component1, :unit_cost => 1000, :quantity => @q
      
      @contract1 = Factory :contract, :project => @project, :component => @component1, :active_bid => Factory( :bid, :raw_cost => 3 )
      @contract2 = Factory :contract, :project => @project, :component => @component2, :active_bid => Factory( :bid, :raw_cost => 30 )
      @contract3 = Factory :contract, :project => @project, :active_bid => Factory( :bid, :raw_cost => 300 )

      [@project, @component2, @task1, @component2, @task2, @l, @lc, @lcl, @mc, @fce1, @fce1, @fce3, @fce4, @q, @uce1, @uce2, @uce3, @uce4, @contract1, @contract2, @contract3].each {|i| i.reload}
    end
    
    #[ {:name => 'fixed cost', :targets => [@fce1, @fce2, @fce3, @fce4]},
    #  {:name => 'unit cost', :targets => [@uce1, @uce2, @uce3, @uce4]},
    #  {:name => 'contract', :targets => [@contract1, @contract2, @contract3]}
    [ {:name => 'fixed cost', :targets => [@fce1, @fce2, @fce3, @fce4]}
    ].each do |data|
      context "with #{data[:name]} invoices & payments" do
        setup do
          puts 'setting up'
          @invoice1 = Factory :invoice, :project => @project
          @invoice1.lines = data[:targets].map { |target|
            puts target
            puts '----'
            Factory( :invoice_line, 
            :invoice => @invoice1,
            :cost => target,
            :labor_invoiced => 4,
            :material_invoiced => 40,
            :labor_retainage => 400,
            :material_retainage => 4000
          ) }
          @invoice2 = Factory :invoice, :project => @project
          @invoice2.lines = data[:targets].map { |target|
            Factory( :invoice_line, 
            :invoice => @invoice2,
            :cost => target,
            :labor_invoiced => 4000,
            :material_invoiced => 40000,
            :labor_retainage => 400000,
            :material_retainage => 4000000
          ) }
                    
          @payment1 = Factory :invoice, :project => @project
          @payment1.lines = data[:targets].map { |target|
            Factory( :payment_line,
            :invoice => @payment1,
            :cost => target,
            :labor_paid => 5,
            :material_paid => 50,
            :labor_retained => 500,
            :material_retained => 5000
          ) }
          @payment2 = Factory :invoice, :project => @project
          @payment2.lines = data[:targets].map { |target|
            Factory( :payment_line,
            :invoice => @payment2,
            :cost => target,
            :labor_paid => 5000,
            :material_paid => 50000,
            :labor_retained => 500000,
            :material_retained => 5000000
          ) }
          
          @obj = data[0]
        end
      
        should "aggregate labor_invoiced" do
          assert_equal 4004, @obj.labor_invoiced
        end
      
        should "aggregate material_invoiced" do
          assert_equal 40040, @obj.material_invoiced
        end
      
        should "aggregate invoiced" do
          assert_equal 44044, @obj.invoiced
        end
      
        should "aggregate labor_retainage" do
          assert_equal 400400, @obj.labor_retainage
        end
      
        should "aggregate material_retainage" do
          assert_equal 4004000, @obj.material_retainage
        end
      
        should "aggregate retainage" do
          assert_equal 4404400, @obj.retainage
        end
      
        should "aggregate labor_paid" do
          assert_equal 5005, @obj.labor_invoiced
        end
      
        should "aggregate material_paid" do
          assert_equal 50050, @obj.material_invoiced
        end
      
        should "aggregate paid" do
          assert_equal 55055, @obj.invoiced
        end
      
        should "aggregate labor_retained" do
          assert_equal 500500, @obj.labor_retainage
        end
      
        should "aggregate material_retained" do
          assert_equal 5005000, @obj.material_retainage
        end
      
        should "aggregate retained" do
          assert_equal 5505500, @obj.retainage
        end
      
        should "determine labor_percent" do
          assert_equal 40, @obj.labor_percent unless @obj.instance_of? Contract
          assert_equal 50, @obj.labor_percent if @obj.instance_of? Contract
        end
      
        should "determine material_percent" do
          assert_equal 60, @obj.material_percent unless @obj.instance_of? Contract
          assert_equal 50, @obj.material_percent if @obj.instance_of? Contract
        end
      
        should "determine labor outstanding" do
          assert_equal 4004-5005, @obj.labor_outstanding
        end
      
        should "determine material_outstanding" do
          assert_equal 40040-50050, @obj.material_outstanding
        end
      
        should "determine outstanding" do
          assert_equal @obj.labor_outstanding + @obj.material_outstanding, @obj.outstanding
        end
      end
    end
  end
end