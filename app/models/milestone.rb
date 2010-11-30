class Milestone < ActiveRecord::Base
  has_paper_trail
  
  belongs_to :project
  belongs_to :task
  belongs_to :parent_date, :polymorphic => true
  
  has_many :relative_milestones, :class_name => 'Milestone', :as => :parent_date, :dependent => :destroy
  
  validates_presence_of :name, :project, :task
  validates_presence_of :parent_date, :unless => :date
  validates_presence_of :interval, :if => :parent_date_id
  
  before_validation :try_inherit_project, :unless => :project_id
  before_save :set_date, :if => :parent_date_id
  after_save :cascade_set_date
  
  # NOTE: the existence of a parent milestone uniquely determines the behavior of the milestone
  # If a parent is set, the date will be updated at each save based on the parent's date and the interval
  scope :absolute, lambda { where( {:parent_date_id => nil} ) }
  scope :relative, lambda { where( 'parent_date_id IS NOT NULL' ) }
  
  def is_absolute?
    self.parent_date.blank?
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
    self.project = self.parent_date.project unless self.parent_date.blank? || self.parent_date.project.blank?
  end
      
  def set_date
    self.date = ( ( self.parent_date.is_complete? ? self.parent_date.date_completed : self.parent_date.date ) + self.interval )
  end
  
  def cascade_set_date
    self.relative_milestones.all.each {|rd| rd.save}
  end
end
