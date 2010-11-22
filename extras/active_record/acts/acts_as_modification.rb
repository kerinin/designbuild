module ActiveRecord
  module Acts
    module Modification
      def self.included(base)
        base.extend(ClassMethods)
      end
      
      module ClassMethods
        def acts_as_modification(attrs={})
          has_many :modifications, :class_name => self.class.name, :foreign_key => :modifies_id
          
          attrs.each do |attr|
            before_save do |base| 
              base.modifications.each do |modification|
                unless !base.send(attr).dirty? || modification.send(attr) != base.send(attr).old_value
                  modification.send(attr) = base.send(attr)
                  modification.save!  
                end
            end
          end    
        end
        
        def has_many_modifiable(*args)
          association_name = args[0]
          association_class = args.has_key?(:class_name) ? args[:class_name] : association_name.classify
        
          has_many(*args, :after_add => "add_#{association_name}_to_modifications")
          
          self.send(:define_method, "add_#{association_name}_to_modifications") do |obj|
            self.modifications.each do |modification|
              clone = obj.clone
              clone.modifies = obj if obj.respond_to?( :modifications )
              clone.save!
              modification.send(association_name) << clone
            end
          end
        end
      end
    end
  end
end
