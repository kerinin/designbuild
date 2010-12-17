require File.dirname(__FILE__) + '/../test_helper'

class InvoicesControllerTest < ActionController::TestCase
  context "An invoice controller" do
    setup do
      # For normal states
      @project1 = Factory :project
      @component1 = Factory :component, :project => @project1
      @task1 = Factory :task, :project => @project1
      @fce1 = Factory :fixed_cost_estimate, :component => @component1, :task => @task1
      
      # For missing task
      @project2 = Factory :project
      @task2 = Factory :task, :project => @project2
      @mc2 = Factory :material_cost, :task => @task2, :raw_cost => 100
      
      # For payments unbalanced
      @project3 = Factory :project
      @component3 = Factory :component, :project => @project3
      @task3 = Factory :task, :project => @project3
      @fce3 = Factory :fixed_cost_estimate, :component => @component3, :task => @task3
      @payment3 = Factory :payment, :project => @project3, :paid => 100
      
      @invoice = Factory :invoice, :project => @project1
      
      @new_invoice = Factory :invoice, :project => @project1
      
      @missing_task_invoice = Factory :invoice, :project => @project2
      @missing_task_invoice.update_attributes(:date => Date::today)
      
      @payments_unbalanced_invoice = Factory :invoice, :project => @project3
      @payments_unbalanced_invoice.update_attributes(:date => Date::today)
      
      @retainage_expected_invoice = Factory :invoice, :project => @project1
      @retainage_expected_invoice.update_attributes(:date => Date::today)
      @retainage_expected_line = @retainage_expected_invoice.lines.first
      
      @retainage_unexpected_invoice = Factory :invoice, :project => @project1
      @retainage_unexpected_invoice.update_attributes(:date => Date::today)
      @retainage_unexpected_line = @retainage_unexpected_invoice.lines.first
      @retainage_unexpected_line.update_attributes(:labor_retainage => 65486432184)
      
      @costs_specified_invoice = Factory :invoice, :project => @project1
      @costs_specified_invoice.update_attributes(:date => Date::today)
      @costs_specified_invoice.accept_costs
      
      @complete_invoice = Factory :invoice, :project => @project1
      @complete_invoice.update_attributes(:date => Date::today)
      @complete_invoice.accept_costs
      @complete_invoice.update_attributes(:template => 'template_AIA_G703')
      
      [@project1, @component1, @task1, @fce1].each {|i| i.reload}
      [@project2, @task2, @mc2].each {|i| i.reload}
      [@project3, @component3, @task3, @fce3, @payment3].each {|i| i.reload}
      [@invoice, @new_invoice, @missing_task_invoice, @payments_unbalanced_invoice, @retainage_expected_invoice, @retainage_unexpected_invoice, @costs_specified_invoice, @complete_invoice].each {|i| i.reload}

      sign_in Factory :user
    end
 
    should "start in expected states" do
      assert_equal 'new', @new_invoice.state
      assert_equal 'missing_task', @missing_task_invoice.state
      #assert_equal 'payments_unbalanced', @payments_unbalanced_invoice.state
      assert_equal 'retainage_expected', @retainage_expected_invoice.state
      assert_equal 'retainage_unexpected', @retainage_unexpected_invoice.state
      assert_equal 'costs_specified', @costs_specified_invoice.state
      assert_equal 'complete', @complete_invoice.state
    end
 
    # Start
    should "get start in state new" do
      get :start, :id => @new_invoice.to_param
      assert_response :success
      assert response.body.include? '<!-- Start -->'
    end

    should "get start in state missing_task" do
      get :start, :id => @missing_task_invoice.to_param
      assert_response :success
      assert response.body.include? '<!-- Missing Task -->'
    end
    
    should_eventually "get start in state payments_unbalanced" do
      get :start, :id => @payments_unbalanced_invoice.to_param
      assert_response :success
      assert response.body.include? '<!-- Payments Unbalanced -->'
    end
    
    should "get start in state retainage_expected" do
      get :start, :id => @retainage_expected_invoice.to_param
      assert_response :success
      assert response.body.include? '<!-- Start -->'
    end
    
    should "get start in state retainage_unexpected" do
      get :start, :id => @retainage_unexpected_invoice.to_param
      assert_response :success
      assert response.body.include? '<!-- Start -->'
    end
    
    should "get start in state costs_specified" do
      get :start, :id => @costs_specified_invoice.to_param
      assert_response :success
      assert response.body.include? '<!-- Start -->'
    end
    
    should "get start in state complete" do
      get :start, :id => @complete_invoice.to_param
      assert_response :success
      assert response.body.include? '<!-- Start -->'
    end
   
    # Set Amounts
    should "get set amounts in state new" do
      get :set_amounts, :id => @new_invoice.to_param
      assert_redirected_to start_invoice_path(assigns(:invoice))
    end
    
    should "get set_amounts in state missing_task" do
      get :set_amounts, :id => @missing_task_invoice.to_param
      assert_redirected_to start_invoice_path(assigns(:invoice))
    end
    
    should_eventually "get set_amounts in state payments_unbalanced" do
      get :set_amounts, :id => @payments_unbalanced_invoice.to_param
      assert_redirected_to start_invoice_path(assigns(:invoice))
    end
    
    should "get set_amounts in state retainage_expected" do
      get :set_amounts, :id => @retainage_expected_invoice.to_param
      assert_response :success
      assert response.body.include? '<!-- Retainage Expected -->'
    end
    
    should "get set_amounts in state retainage_unexpected" do
      get :set_amounts, :id => @retainage_unexpected_invoice.to_param
      assert_response :success
      assert response.body.include? '<!-- Retainage Unexpected -->'
    end
    
    should "get set_amounts in state costs_specified" do
      get :set_amounts, :id => @costs_specified_invoice.to_param
      assert_response :success
      assert response.body.include? '<!-- Retainage Expected -->'
    end
    
    should "get set_amounts in state complete" do
      get :set_amounts, :id => @complete_invoice.to_param
      assert_response :success
      assert response.body.include? '<!-- Retainage Expected -->'
    end
    
    # Select Template
    should "get select template in state new" do
      get :select_template, :id => @invoice.to_param
      assert_redirected_to start_invoice_path(assigns(:invoice))
    end
    
    should "get select_template in state missing_task" do
      get :select_template, :id => @missing_task_invoice.to_param
      assert_redirected_to start_invoice_path(assigns(:invoice))
    end
    
    should_eventually "get select_template in state payments_unbalanced" do
      get :select_template, :id => @payments_unbalanced_invoice.to_param
      assert_redirected_to start_invoice_path(assigns(:invoice))
    end
    
    should "get select_template in state retainage_expected" do
      get :select_template, :id => @retainage_expected_invoice.to_param
      assert_redirected_to set_amounts_invoice_path(assigns(:invoice))
    end
    
    should "get select_template in state retainage_unexpected" do
      get :select_template, :id => @retainage_unexpected_invoice.to_param
      assert_redirected_to set_amounts_invoice_path(assigns(:invoice))
    end
    
    should "get select_template in state costs_specified" do
      get :select_template, :id => @costs_specified_invoice.to_param
      assert_response :success
    end
    
    should "get select_template in state complete" do
      get :select_template, :id => @complete_invoice.to_param
      assert_response :success
    end
     
    # Finished
    should "get finished" do
      get :finished, :id => @invoice.to_param
    end
    
    should "get finished in state missing_task" do
      get :finished, :id => @missing_task_invoice.to_param
      assert_redirected_to start_invoice_path(assigns(:invoice))
    end
    
    should_eventually "get finished in state payments_unbalanced" do
      get :finished, :id => @payments_unbalanced_invoice.to_param
      assert_redirected_to start_invoice_path(assigns(:invoice))
    end
    
    should "get finished in state retainage_expected" do
      get :finished, :id => @retainage_expected_invoice.to_param
      assert_redirected_to set_amounts_invoice_path(assigns(:invoice))
    end
    
    should "get finished in state retainage_unexpected" do
      get :finished, :id => @retainage_unexpected_invoice.to_param
      assert_redirected_to set_amounts_invoice_path(assigns(:invoice))
    end
    
    should "get finished in state costs_specified" do
      get :finished, :id => @costs_specified_invoice.to_param
      assert_redirected_to select_template_invoice_path(assigns(:invoice))
    end
    
    should "get finished in state complete" do
      get :finished, :id => @complete_invoice.to_param
      assert_response :success
    end
   
    # Accept Costs
    should "accept costs in state retainage_expected" do
      get :accept, :id => @retainage_expected_invoice.to_param
      
      assert_redirected_to select_template_invoice_path(assigns(:invoice))
      assert_equal 'costs_specified', assigns(:invoice).state
    end
    
    should "accept costs in state retainage_unexpected" do
      get :accept, :id => @retainage_unexpected_invoice.to_param
      
      assert_redirected_to select_template_invoice_path(assigns(:invoice))
      assert_equal 'costs_specified', assigns(:invoice).state
    end
    
    # CRUD
    
    should "get index" do
      get :index, :project_id => @project1.to_param
      assert_response :success
      assert_not_nil assigns(:invoices)
    end

    #should "get new" do
    #  get :new, :project_id => @project.to_param
    #  assert_response :success
    #end

    should "create invoice" do
      assert_difference('Invoice.count') do
        post :create, :project_id => @project1.to_param, :invoice => @invoice.attributes
      end

      assert_redirected_to start_invoice_path(assigns(:invoice))
    end

    #should "show invoice" do
    #  get :show, :project_id => @project.to_param, :id => @invoice.to_param
    #  assert_response :success
    #end
    
    should "get edit" do
      get :edit, :project_id => @project1.to_param, :id => @invoice.to_param
      assert_response :success
    end


    should "update new invoice" do
      put :update, :project_id => @project1.to_param, :id => @new_invoice.to_param, :invoice => {
        :date => Date::today, :name => 'foo'
      }
      assert_redirected_to set_amounts_invoice_path(assigns(:invoice))
    end
        
    should_eventually "update payments_unbalanced invoice" do
      put :update, :project_id => @project1.to_param, :id => @payments_unbalanced_invoice.to_param, :invoice => {
        :date => Date::today, :name => 'foo'
      }
      assert_redirected_to set_amounts_invoice_path(assigns(:invoice))
    end
    
    should "update retainage_expected invoice" do
      put :update, :project_id => @project1.to_param, :id => @retainage_expected_invoice.to_param, :invoice => { :lines_attributes => {:line => {
        :id => @retainage_expected_line.to_param, :labor_invoiced => 1, :material_invoiced => 10, :labor_retainage => 100, :material_retainage => 1000
      } } }
      
      # Redirects after accept_costs
      assert_redirected_to set_amounts_invoice_path(assigns(:invoice))
    end
    
    should "fail to update retainage_expected invoice" do
      put :update, :project_id => @project1.to_param, :id => @retainage_expected_invoice.to_param, :invoice => { :lines_attributes => {:line => {
        :id => @retainage_expected_line.to_param, :labor_invoiced => 'foo', :material_invoiced => 'foo', :labor_retainage => 'foo', :material_retainage => 'foo'
      } } }
      
      # Redirects after accept_costs
      assert_equal false, assigns(:invoice).valid?
      assert_redirected_to set_amounts_invoice_path(assigns(:invoice))
    end
    
    should "update retainage_unexpected invoice" do
      put :update, :project_id => @project1.to_param, :id => @retainage_unexpected_invoice.to_param, :invoice => { :lines_attributes => {:line => {
        :id => @retainage_unexpected_line.to_param, :labor_invoiced => 1, :material_invoiced => 10, :labor_retainage => 100, :material_retainage => 1000
      } } }
      
      # Redirects after accept_costs
      assert_redirected_to set_amounts_invoice_path(assigns(:invoice))
    end
    
    should "fail to update retainage_unexpected invoice" do
      put :update, :project_id => @project1.to_param, :id => @retainage_unexpected_invoice.to_param, :invoice => { :lines_attributes => {:line => {
        :id => @retainage_unexpected_line.to_param, :labor_invoiced => 'foo', :material_invoiced => 'foo', :labor_retainage => 'foo', :material_retainage => 'foo'
      } } }
      
      # Redirects after accept_costs
      assert_equal false, assigns(:invoice).valid?
      assert_redirected_to set_amounts_invoice_path(assigns(:invoice))
    end
    
    should "update costs_specified invoice" do
      put :update, :project_id => @project1.to_param, :id => @costs_specified_invoice.to_param, :invoice => {
        :template => 'template_AIA_G703'
      }
      assert_redirected_to finished_invoice_path(assigns(:invoice))
    end
    
    should_eventually "fail to update costs_specified invoice" do
      put :update, :project_id => @project1.to_param, :id => @costs_specified_invoice.to_param, :invoice => {
        :template => 'foo'
      }
      assert_equal false, assigns(:invoice).valid?
      assert_redirected_to costs_specified_invoice_path(assigns(:invoice))
    end
    
    should "destroy invoice" do
      assert_difference('Invoice.count', -1) do
        delete :destroy, :project_id => @project1.to_param, :id => @invoice.to_param
      end

      assert_redirected_to project_invoices_path(@project1)
    end
  end
end
