class Marking < ActiveRecord::Base
  has_paper_trail :ignore => [:created_at, :updated_at]
  
  belongs_to :markupable, :polymorphic => true

  belongs_to :markup
end
