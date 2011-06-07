class Resource < ActiveRecord::Base
  has_many :resource_allocations
  
  has_and_belongs_to_many :resource_requests
  
  default_scope :order => :name
  
  validates_presence_of :name
end