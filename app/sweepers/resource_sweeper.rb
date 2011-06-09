class ResourceSweeper < ActionController::Caching::Sweeper
  observe Resource
  
  def after_create(resource)
    expire_cache_for resource
  end

  def after_update(resource)
    expire_cache_for resource
  end

  def after_destroy(resource)
    expire_cache_for resource
  end

  private
  
  def expire_cache_for(resource)
    expire_fragment("project_nav")
    Project.all.each do |project|
      expire_fragment("project_nav_#{project.id}")
    end
  end  
end
