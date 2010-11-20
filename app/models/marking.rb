class Marking < ActiveRecord::Base
  belongs_to :markupable, :polymorphic => true

  belongs_to :markup
end
