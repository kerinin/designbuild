class Markup < ActiveRecord::Base
  belongs_to :parent, :polymorphic => true
  
  validates_presence_of :parent
end
