Designbuild::Application.routes.draw do
  
  resources :invoices do
    resources :invoice_lines
    resources :invoice_lines, :as => :line_items
    resources :invoice_markup_lines
    resources :invoice_markup_lines, :as => :markups
    
    member do
      get :start
      get :assign_costs
      get :set_amounts
      get :add_markups
      get :select_template
      get :finished
      
      get :accept_costs
      get :accept_markups
    end
  end  

  resources :payments do
    resources :payment_lines
    resources :payment_lines, :as => :line_items
    resources :payment_markup_lines
    resources :payment_markup_lines, :as => :markups

    member do
      get :start
      get :balance
      get :finished
      
      get :accept
    end
  end
    
  resources :milestones

  resources :suppliers
  
  resources :laborers  
  
  resources :projects do
    resources :components do
      member do
        get :changelog
        get :new_cost
        post :sort
      end
      collection do
        post :sort
      end
    end
    resources :tasks        # re-nested
    
    resources :contracts do
      collection do
        post :sort
      end
    end
    
    resources :deadlines    # re-nested
    
    resources :invoices     # re-nested
    resources :payments     # re-nested
    
    member do
      post :add_markup, :as => :add_markup_to
      get :autocomplete_task_name
    end
    
    resources :markups do
      member do
        get :add, :action => :add_to_project
        get :remove, :action => :remove_from_project
      end
    end
    
    member do
      get :timeline, :as => :timeline_for
      get :estimate_report, :as => :estimate_report_for
      get :cost_report, :as => :cost_report_for
      get :purchase_order_list, :as => :purchase_order_list_for
      get :labor_summary, :as => :labor_summary_for
      get :payroll_summary, :as => :payroll_summary_for
      get :material_cost_summary, :as => :material_cost_summary_for
      get :invoicing
    end
    
    collection do
      get :purchase_order_list
      get :labor_summary
      get :payroll_summary
      get :material_cost_summary
    end
  end

  resources :components do
    resources :quantities
    resources :fixed_cost_estimates
    resources :unit_cost_estimates
    resources :contracts
    resources :markups
    resources :components, :as => :subcomponents, :path => :subcomponents
    
    member do
      post :add_markup, :as => :add_markup_to
      get :changelog
    end
    
    resources :markups, :only => [:new, :create, :edit, :update] do
      member do
        get :add, :action => :add_to_component
        get :remove, :action => :remove_from_component
      end
    end
  end
    
  resources :tasks do
    resources :labor_costs        # re-nested
    resources :material_costs     # re-nested
    resource :deadline

    member do
      post :add_markup, :as => :add_markup_to
      get :estimated_costs
      get :scheduling
      get :costs
    end
    
    resources :markups do
      member do
        get :add, :action => :add_to_task
        get :remove, :action => :remove_from_task
      end
    end
    
    resources :unit_cost_estimates do
      member do
        get :add, :action => :add_to_task
        get :remove, :action => :remove_from_task
      end
    end
    
    resources :fixed_cost_estimates do
      member do
        get :add, :action => :add_to_task
        get :remove, :action => :remove_from_task
      end
    end
  end
    
  resources :labor_costs do    
    resources :labor_cost_lines, :as => :line_items
  end
  
  resources :material_costs do
    resources :material_cost_lines, :as => :line_items
    get :autocomplete_supplier_name, :on => :collection
  end
  
  resources :contracts do
    resources :bids
    resources :contract_costs

    member do
      post :add_markup, :as => :add_markup_to
    end
    
    resources :markups do
      member do
        get :add, :action => :add_to_contract
        get :remove, :action => :remove_from_contract
      end
    end
  end

  resources :tags
  
  resources :markups
  
  namespace :admin do
    resources :users
  end
  
  devise_for :users
  
  match 'reports', :controller => :reports, :action => :index, :as => :reports
  match 'reports/:action', :controller => :reports
  
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "welcome#index"
  #as :user do
  #  root :to => "devise/sessions#new"
  #end
  root :to => "projects#index"
  
  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
