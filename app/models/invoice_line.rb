class InvoiceLine < ActiveRecord::Base
  belongs_to :invoice
  belongs_to :component
end
