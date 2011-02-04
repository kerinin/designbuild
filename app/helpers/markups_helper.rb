module MarkupsHelper
  def get_redirect
    case
    when params.has_key?( :project_id )
      project_markups_path(@parent)
    when params.has_key?( :component_id )
      component_markups_path(@parent)
    when params.has_key?( :task_id )
      task_markups_path(@parent)
    end
  end
end
