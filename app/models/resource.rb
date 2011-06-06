class Resource < ActiveRecord::Base
  has_many :resource_requests
  has_many :resource_allocations
  
  default_scope :order => :name
end