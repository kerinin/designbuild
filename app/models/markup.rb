class Markup < ActiveRecord::Base
  has_many :markings, :dependent => :destroy
  
  has_many :projects, :through => :markings, :source => :markupable, :source_type => 'Project'
  has_many :tasks, :through => :markings, :source => :markupable, :source_type => 'Task'
  has_many :components, :through => :markings, :source => :markupable, :source_type => 'Component'
  has_many :contracts, :through => :markings, :source => :markupable, :source_type => 'Contract'
end
