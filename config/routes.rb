Designbuild::Application.routes.draw do

  resources :projects do
    resources :suppliers
    resources :laborers     
    resources :components   # re-nested  
    resources :tasks        # re-nested
    resources :contracts    # re-nested
    resources :deadlines    # re-nested
    
    member do
      get :timeline_events, :as => :timeline_events_for
    end
  end

  resources :components do
    resources :quantities
    resources :fixed_cost_estimates
    resources :unit_cost_estimates
  end
    
  resources :tasks do
    resources :labor_costs        # re-nested
    resources :material_costs     # re-nested
  end
    
  resources :labor_costs do    
    resources :labor_cost_lines, :as => :line_items
  end
  
  resources :material_costs do
    resources :material_cost_lines, :as => :line_items
  end
  
  resources :contracts do
    resources :bids
    resources :contract_costs
  end

  resources :deadlines do
    resources :relative_deadlines
  end
    
  resources :tags

  devise_for :users
  
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
