class DatePoint < ActiveRecord::Base
  belongs_to :source, :polymorphic => true
  
  validates_uniqueness_of :date, :scope => [:source_id, :source_typ, :series]
  validates_presence_of :date, :value, :source, :series
end
