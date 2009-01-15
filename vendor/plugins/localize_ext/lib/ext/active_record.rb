module ActiveRecord
  class Base
    class << self
      def human_attribute_name_with_localize_ext(attr_name)
        lz_caller = "%s/app/models/%s.rb:0:in `human_attribute_name'" % [RAILS_ROOT, self.to_s.underscore]
        LocalizeExt::Helper.translate_caller(lz_caller, "translations", attr_name.to_sym, nil, human_attribute_name_without_localize_ext(attr_name))
      end  
      alias_method_chain :human_attribute_name, :localize_ext
    end
  end
end