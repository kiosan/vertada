module LocalizeExt::LanguageRules::Extensions
  class UK_UA
    def self.plural_key(count, key)
      key_string = key.to_s 
      case count
        when 0 then key_string  
        when 1 then key_string += '_1'
        when 2..4 then key_string += '_2'
        when 5..20 then key_string
        else key_string = plural_key(count.divmod(10)[1], key) 
      end
      key_string.to_sym
    end  
  end
end