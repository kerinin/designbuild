class Markup < ActiveRecord::Base
  include AddOrNil
  
  has_paper_trail :ignore => [:created_at, :updated_at]
  
  has_many :markings, :dependent => :destroy
  
  has_many :projects, :through => :markings, :source => :markupable, :source_type => 'Project', :after_add => :cascade_add, :before_remove => :cascade_remove
  has_many :tasks, :through => :markings, :source => :markupable, :source_type => 'Task', :after_add => Proc.new{|m,t| t.save}, :after_remove => Proc.new{|m,t| t.save}
  has_many :components, :through => :markings, :source => :markupable, :source_type => 'Component', :after_add => :cascade_add, :before_remove => :cascade_remove
  has_many :contracts, :through => :markings, :source => :markupable, :source_type => 'Contract', :after_add => Proc.new{|m,c| c.save}, :after_remove => Proc.new{|m,c| c.save}
  
  accepts_nested_attributes_for :markings
  
  validates_presence_of :name, :percent
  
  before_save {|r| @new_markings = r.markings.map {|m| ( m.new_record? && (m.markupable_type == 'Project' || m.markupable_type == 'Component') ) ? m : nil }.compact }
  after_save {|r| @new_markings.each {|m| r.cascade_add(m.markupable)} }
  after_save :cascade_cache_values
  after_destroy :cascade_cache_values
  
  def apply_to(value, scope = :estimated)
    case
    when value.instance_of?( Float ) || value.instance_of?( Integer )
      multiply_or_nil( value, divide_or_nil(self.percent, 100) )
      
    # Distribute to project associations
    when value.instance_of?( Project ) && scope == :estimated
      (value.components.scoped & self.components.scoped).inject(0) {|memo,obj| memo + self.apply_to(obj,scope)} + 
      (value.contracts.without_component.scoped & self.contracts.scoped).inject(0) {|memo,obj| memo + self.apply_to(obj,scope)}

    # Estimated cost
    when value.instance_of?( Component ) && scope == :estimated
      if value.markups.include? self
        self.apply_to value.estimated_raw_component_cost
      else
        0
      end
    when value.instance_of?( Contract ) && scope == :estimated
      if value.markups.include? self
        self.apply_to value.estimated_raw_cost
      end

    # Default
    else
      0
    end
  end
  
  def cascade_add(obj)
    obj.send :cascade_add_markup, self
  end
  
  def cascade_remove(obj)
    obj.send :cascade_remove_markup, self
  end
  
  def select_label
    "#{self.name} (#{self.percent}%)"
  end

  def cascade_cache_values
    self.tasks.all.each {|t| t.save!}
    self.contracts.all.each {|c| c.save!}
    self.components.all.each {|c| c.save!}
  end
end
