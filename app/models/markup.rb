class Markup < ActiveRecord::Base
  has_many :markings, :dependent => :destroy
  
  has_many :projects, :through => :markings, :source => :markupable, :source_type => 'Project', :after_add => :cascade_add, :before_remove => :cascade_remove
  has_many :tasks, :through => :markings, :source => :markupable, :source_type => 'Task'
  has_many :components, :through => :markings, :source => :markupable, :source_type => 'Component', :after_add => :cascade_add, :before_remove => :cascade_remove
  has_many :contracts, :through => :markings, :source => :markupable, :source_type => 'Contract'
  
  def cascade_add(obj)
    obj.send :cascade_add_markup, self
  end
  
  def cascade_remove(obj)
    obj.send :cascade_remove_markup, self
  end
end
