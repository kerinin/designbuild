module MarkupsHelper
  def get_redirect
    case
    when params.has_key?( :project_id )
      project_path(@parent)
    when params.has_key?( :component_id )
      project_component_path(@parent.project, @parent)
    when params.has_key?( :task_id )
      project_task_path(@parent.project, @parent)
    when params.has_key?( :contract_id )
      project_contract_path(@parent.project, @parent)
    end
  end
end
