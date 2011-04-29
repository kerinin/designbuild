class InvoiceMarkupLine < ActiveRecord::Base
  include AddOrNil

  belongs_to :invoice, :inverse_of => :markup_lines #, :autosave => true
  belongs_to :markup, :inverse_of => :invoice_markup_lines

  validates_presence_of :invoice, :markup
  validates_numericality_of :labor_invoiced, :labor_retainage, :material_invoiced, :material_retainage

  before_create :set_defaults
  before_save :set_sums

  def retainage_as_expected?
    # I think this is required because we can't do polymorphic inverse_of
    # As such, the cost's labor_retainage doesn't get updated (on self's cached version)
    # if another invoice line is changed
    self.component.reload
    expected_labor = calculate_retainage( 
      self.labor_invoiced + self.component.labor_invoiced, 
      self.invoice.project.labor_percent_retainage_float, 
      self.component.labor_retainage 
    )

    expected_material = calculate_retainage( 
      self.material_invoiced + self.component.material_invoiced, 
      self.invoice.project.material_percent_retainage_float, 
      self.component.material_retainage 
    )

    expected_labor.round(2) == self.labor_retainage.round(2) && expected_material.round(2) == self.material_retainage.round(2)
  end

  def calculate_retainage( invoiced, retainage_float, retainage)
    ( invoiced * retainage_float / ( 1 - retainage_float ) ) - retainage
  end
  
  [:expected_labor_invoiced, :expected_labor_retainage, :expected_material_invoiced, :expected_material_retainage].each do |sym|
    self.send(:define_method, sym) do
      self.markup.apply_to(self.invoice.lines.includes(:component => :markups).where('markups.id = ?', self.markup_id).sum(sym.to_s.sub('expected_','')))
    end
  end
  
  def set_defaults
    [:labor_invoiced, :labor_retainage, :material_invoiced, :material_retainage].each do |sym|
      self.send("#{sym.to_s}=", self.send("expected_#{sym.to_s}"))
    end
    self.set_sums
  end
  
  protected

  def set_sums
    self.invoiced = self.labor_invoiced + self.material_invoiced
    self.retainage = self.labor_retainage + self.material_retainage
  end
end

