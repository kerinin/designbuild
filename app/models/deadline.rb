class Deadline < ActiveRecord::Base
  has_paper_trail
  
  belongs_to :project
  belongs_to :parent_deadline, :class_name => "Deadline"
  
  has_many :tasks
  has_many :relative_deadlines, :class_name => 'Deadline', :foreign_key => :parent_deadline_id, :dependent => :destroy
  has_many :relative_milestones, :class_name => 'Milestone', :as => :parent_date, :dependent => :destroy
  
  validates_presence_of :name, :project
  validates_presence_of :parent_deadline_id, :unless => :date
  validates_presence_of :interval, :if => :parent_deadline_id
  
  before_validation :try_inherit_project, :unless => :project_id
  before_save :set_date, :if => :parent_deadline_id
  after_save :cascade_set_date
  
  # NOTE: the existence of a parent deadline uniquely determines the behavior of the deadline
  # If a parent is set, the date will be updated at each save based on the parent's date and the interval
  scope :absolute, lambda { where( {:parent_deadline_id => nil} ) }
  scope :relative, lambda { where( 'parent_deadline_id IS NOT NULL' ) }
  
  def is_absolute?
    self.parent_deadline.blank?
  end
  
  def is_relative?
    !self.is_absolute?
  end
  
  def is_complete?
    !self.date_completed.nil?
  end
  
  def select_label
    "#{self.name} - #{self.date.to_s :long}"
  end

  def select_label_short
    "#{self.name} - #{self.date.to_s :short}"
  end
    
  protected
  
  def try_inherit_project
    self.project = self.parent_deadline.project unless self.parent_deadline.blank? || self.parent_deadline.project.blank?
  end
      
  def set_date
    self.date = ( ( self.parent_deadline.is_complete? ? self.parent_deadline.date_completed : self.parent_deadline.date ) + self.interval )
  end
  
  def cascade_set_date
    self.relative_deadlines.all.each {|rd| rd.save}
    self.relative_milestones.all.each {|rm| rm.save}
  end
end
