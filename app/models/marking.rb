class Marking < ActiveRecord::Base
  has_paper_trail
  
  belongs_to :markupable, :polymorphic => true

  belongs_to :markup
end
