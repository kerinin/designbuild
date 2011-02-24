class ProjectSweeper < ActionController::Caching::Sweeper
  observe Project
  
  def after_create(project)
    expire_cache_for project
  end

  def after_update(project)
    expire_cache_for project
  end

  def after_destroy(project)
    expire_cache_for project
  end

  private
  
  def expire_cache_for(project)
    expire fragment("project_nav")
    expire fragment("project_nav_#{project.id}")
  end  
end
