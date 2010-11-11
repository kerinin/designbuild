class Task < ActiveRecord::Base
  belongs_to :estimate, :polymorphic => true
end
