module MarksUp
  include AddOrNil
  
  def self.included(base)
    base.send :extend, ClassMethods
  end
  
  module ClassMethods
    def marks_up(sym)
      method = sym.to_s.gsub(/raw_/,'')
      self.send(:define_method, method) do |*args|
        if self.total_markup.nil?
          return self.send(sym, *args)
        else
          multiply_or_nil self.send(sym, *args), ( add_or_nil( 1, ( divide_or_nil( self.total_markup, 100 ) ) ) )
        end
      end
    end
  end
end

