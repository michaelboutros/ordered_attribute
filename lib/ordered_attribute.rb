module OrderedAttribute
  class Railtie < Rails::Railtie
    initializer 'ordered_attribute.insert_into_active_record' do
      ActiveSupport.on_load :active_record do
        ActiveRecord::Base.extend OrderedAttribute::ClassMethods
      end
    end
  end

  module ClassMethods
    def has_ordered_attribute(attribute_name, parent_association = nil)
      parent_name ||= self.reflect_on_all_associations(:belongs_to).first.name  
      parent_klass = self.reflect_on_association(parent_name).klass

      child_association = parent_klass.reflect_on_all_associations.select do |a| 
        a.class_name == self.model_name rescue next
      end.first
      
      child_name = child_association.name.to_s.singularize
      child_plural_name = child_association.name.to_s

      association = "#{parent_name}.#{child_plural_name}"
      
      class_eval %Q{
        before_create do
          other_items = #{association}
          self.#{attribute_name} = other_items.empty? ? 1 : other_items.length + 1
        end

        before_destroy do
          start = #{attribute_name} + 1
          length = #{association}.length

          #{association}.where(:order => (start..length)).each do |item|
            item.decrement!(:#{attribute_name})
          end
        end

        def #{child_name}_before
          #{association}.first(:conditions => {:#{attribute_name} => #{attribute_name} - 1})
        end

        def #{child_name}_after
          #{association}.first(:conditions => {:#{attribute_name} => #{attribute_name} + 1})
        end

        def move_up!
          unless #{attribute_name} == 1
            #{child_name}_before.increment!(:#{attribute_name})
            decrement!(:#{attribute_name})   
          end
        end

        def move_down!
          unless #{attribute_name} == #{association}.length
            #{child_name}_after.decrement!(:#{attribute_name})
            increment!(:#{attribute_name})   
          end
        end}
    end
  end
end