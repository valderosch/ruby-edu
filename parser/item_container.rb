module ItemContainer
  module ClassMethods
    def default_location
      'Online|Def'
    end

    def item_count(items)
      items.length
    end
  end

  module InstanceMethods
    def add_item(item)
      items << item
    end

    def remove_item(item)
      items.delete(item)
    end

    def delete_items
      items.clear
    end

    def method_missing(method_name, *args, &block)
      if method_name.to_s.start_with?('show_all_items')
        items.each { |item| puts item.to_s }
      else
        super
      end
    end
  end

  def self.included(class_instance)
    class_instance.extend(ClassMethods)
    class_instance.send :include, InstanceMethods
  end
end