class Project < ActiveRecord::Base
  has_and_belongs_to_many :users
  has_many :components
  has_many :tasks
  has_many :contracts
  has_many :deadlines
end
