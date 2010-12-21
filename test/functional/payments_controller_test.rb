require File.dirname(__FILE__) + '/../test_helper'

class PaymentsControllerTest < ActionController::TestCase
  context "A payment controller" do
    setup do
      # For normal states
      @l = Factory :laborer, :bill_rate => 1
      @project1 = Factory :project
      @component1 = Factory :component, :project => @project1
      @task1 = Factory :task, :project => @project1
      @fce1 = Factory :fixed_cost_estimate, :component => @component1, :task => @task1
      @lc1 = Factory :labor_cost, :task => @task1, :date => Date::today, :percent_complete => 100
      @lcl1 = Factory :labor_cost_line, :labor_set => @lc1, :laborer => @l, :hours => 10
      @mc1 = Factory :material_cost, :task => @task1, :date => Date::today, :raw_cost => 100
      
      # For missing task
      @project2 = Factory :project
      @task2 = Factory :task, :project => @project2
      @mc2 = Factory :material_cost, :task => @task2, :raw_cost => 100

      @complete_invoice = Factory :invoice, :project => @project1
      @complete_invoice.update_attributes(:date => Date::today)
      @complete_invoice.accept_costs
      @complete_invoice.update_attributes(:template => 'template_AIA_G703')
      
      @payment = Factory :payment, :project => @project1
      
      @new_payment = Factory :payment, :project => @project1
      
      @missing_task_payment = Factory :payment, :project => @project2
      @missing_task_payment.update_attributes(:date => Date::today, :paid => 110, :retained => 0)
      
      @balanced_payment = Factory :payment, :project => @project1
      @balanced_payment.update_attributes(:date => Date::today, :paid => 110, :retained => 0)
      @balanced_line = @balanced_payment.lines.first
      
      @complete_payment = Factory :payment, :project => @project1
      @complete_payment.update_attributes(:date => Date::today, :paid => 0, :retained => 0)
      @complete_payment.accept_payment

      @unbalanced_payment = Factory :payment, :project => @project1
      @unbalanced_payment.update_attributes(:date => Date::today, :paid => 110, :retained => 0)
      @unbalanced_line = @unbalanced_payment.lines.first
      @unbalanced_line.update_attributes(:labor_paid => 65486432184)
      
      [@l, @project1, @component1, @task1, @fce1, @lc1, @lcl1, @mc1].each {|i| i.reload}
      [@project2, @task2, @mc2].each {|i| i.reload}
      [@payment, @new_payment, @missing_task_payment, @balanced_payment, @balanced_line, @unbalanced_payment, @unbalanced_line, @complete_payment].each {|i| i.reload}

      sign_in Factory :user
    end

    should "start in expected states" do
      assert_equal 'new', @new_payment.state
      assert_equal 'missing_task', @missing_task_payment.state
      assert_equal 'balanced', @balanced_payment.state
      assert_equal 'unbalanced', @unbalanced_payment.state
      assert_equal 'complete', @complete_payment.state
    end
 
    # Start
    should "get start in state new" do
      get :start, :id => @new_payment.to_param
      assert_response :success
      assert response.body.include? '<!-- Start -->'
    end

    should "get start in state missing_task" do
      get :start, :id => @missing_task_payment.to_param
      assert_response :success
      assert response.body.include? '<!-- Missing Task -->'
    end
    
    should "get start in state balanced" do
      get :start, :id => @balanced_payment.to_param
      assert_response :success
      assert response.body.include? '<!-- Start -->'
    end
    
    should "get start in state unbalanced" do
      get :start, :id => @unbalanced_payment.to_param
      assert_response :success
      assert response.body.include? '<!-- Start -->'
    end
    
    should "get start in state complete" do
      get :start, :id => @complete_payment.to_param
      assert_response :success
      assert response.body.include? '<!-- Start -->'
    end
  
    # Balance
    should "get balance in state new" do
      get :balance, :id => @new_payment.to_param
      assert_redirected_to start_payment_path(assigns(:payment))
    end
    
    should "get balance in state missing_task" do
      get :balance, :id => @missing_task_payment.to_param
      assert_redirected_to start_payment_path(assigns(:payment))
    end
    
    should "get balance in state balanced" do
      get :balance, :id => @balanced_payment.to_param
      assert_response :success
      assert response.body.include? '<!-- Balanced -->'
    end
    
    should "get balance in state unbalanced" do
      get :balance, :id => @unbalanced_payment.to_param
      assert_response :success
      assert response.body.include? '<!-- Unbalanced -->'
    end
    
    should "get balance in state complete" do
      get :balance, :id => @complete_payment.to_param
      assert_response :success
      assert response.body.include? '<!-- Balanced -->'
    end
     
    # Finished
    should "get finished in state new" do
      get :finished, :id => @new_payment.to_param
      assert_redirected_to start_payment_path(assigns(:invoice))
    end
    
    should "get finished in state missing_task" do
      get :finished, :id => @missing_task_payment.to_param
      assert_redirected_to start_payment_path(assigns(:invoice))
    end
    
    should "get finished in state balanced" do
      get :finished, :id => @balanced_payment.to_param
      assert_redirected_to balance_payment_path(assigns(:payment))
    end
    
    should "get finished in state unbalanced" do
      get :finished, :id => @unbalanced_payment.to_param
      assert_redirected_to balance_payment_path(assigns(:payment))
    end
    
    should "get finished in state complete" do
      get :finished, :id => @complete_payment.to_param
      assert_response :success
    end
   
    # Accept Payment
    should "accept payment in state balanced" do
      get :accept, :id => @balanced_payment.to_param
      
      assert_redirected_to finished_payment_path(assigns(:payment))
      assert_equal 'complete', assigns(:payment).state
    end
    
    should "not accept payment in state unbalanced" do
      get :accept, :id => @unbalanced_payment.to_param
      
      assert_redirected_to balance_payment_path(assigns(:payment))
      assert_equal 'unbalanced', assigns(:payment).state
    end
   
    # CRUD
    
    should "get index" do
      get :index, :project_id => @project1.to_param
      assert_response :success
      assert_not_nil assigns(:payments)
    end

    #should "get new" do
    #  get :new, :project_id => @project.to_param
    #  assert_response :success
    #end

    should "create payment" do
      assert_difference('Payment.count') do
        post :create, :project_id => @project1.to_param, :payment => @payment.attributes
      end

      assert_redirected_to start_payment_path(assigns(:payment))
    end

    #should "show invoice" do
    #  get :show, :project_id => @project.to_param, :id => @invoice.to_param
    #  assert_response :success
    #end
    
    should "get edit" do
      get :edit, :project_id => @project1.to_param, :id => @payment.to_param
      assert_response :success
    end


    should "update new payment" do
      put :update, :project_id => @project1.to_param, :id => @new_payment.to_param, :payment => {
        :date => Date::today, :paid => 100, :retained => 100
      }
      assert_redirected_to balance_payment_path(assigns(:payment))
    end
    
    should "update balanced payment" do
      put :update, :project_id => @project1.to_param, :id => @balanced_payment.to_param, :payment => { :lines_attributes => {:line => {
        :id => @balanced_line.to_param, :labor_paid => 1, :material_paid => 10, :labor_retained => 100, :material_retained => 1000
      } } }
      
      # Redirects after accept_costs
      assert_redirected_to balance_payment_path(assigns(:payment))
      assert_equal 1, @balanced_line.reload.labor_paid
      assert_equal 10, @balanced_line.reload.material_paid
      assert_equal 100, @balanced_line.reload.labor_retained
      assert_equal 1000, @balanced_line.reload.material_retained
    end
    
    should "fail to update balanced payment" do
      put :update, :project_id => @project1.to_param, :id => @balanced_payment.to_param, :payment => { :lines_attributes => {:line => {
        :id => @balanced_line.to_param, :labor_paid => 'foo', :material_paid => 'foo', :labor_retained => 'foo', :material_retained => 'foo'
      } } }
      
      # Redirects after accept_costs
      assert_equal false, assigns(:payment).valid?
      assert_redirected_to balance_payment_path(assigns(:payment))
    end
    
    should "update unbalanced payment" do
      put :update, :project_id => @project1.to_param, :id => @unbalanced_payment.to_param, :payment => { :lines_attributes => {:line => {
        :id => @unbalanced_line.to_param, :labor_paid => 1, :material_paid => 10, :labor_retained => 100, :material_retained => 1000
      } } }
      
      # Redirects after accept_costs
      assert_redirected_to balance_payment_path(assigns(:payment))
      assert_equal 1, @unbalanced_line.reload.labor_paid
      assert_equal 10, @unbalanced_line.reload.material_paid
      assert_equal 100, @unbalanced_line.reload.labor_retained
      assert_equal 1000, @unbalanced_line.reload.material_retained
    end
    
    should "fail to update unbalanced payment" do
      put :update, :project_id => @project1.to_param, :id => @unbalanced_payment.to_param, :payment => { :lines_attributes => {:line => {
        :id => @unbalanced_line.to_param, :labor_paid => 'foo', :material_paid => 'foo', :labor_retained => 'foo', :material_retained => 'foo'
      } } }
      
      # Redirects after accept_costs
      assert_equal false, assigns(:payment).valid?
      assert_redirected_to balance_payment_path(assigns(:payment))
    end
    
    should "destroy payment" do
      assert_difference('Payment.count', -1) do
        delete :destroy, :project_id => @project1.to_param, :id => @payment.to_param
      end

      assert_redirected_to project_payments_path(@project1)
    end

  end
end

