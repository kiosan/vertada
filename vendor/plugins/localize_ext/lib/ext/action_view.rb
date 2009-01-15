module ActionView
  class Template
    def find_full_path_with_localize_ext(path, load_paths)
      path, filename = find_full_path_without_localize_ext(path, load_paths)
      lz_filename = LocalizeExt::Helper.localized_path(filename)
      filename = lz_filename if File.exists?(lz_filename) and not File.directory?(lz_filename)
      return path, filename
    end
    alias_method_chain :find_full_path, :localize_ext
  end
    
  module Helpers
    # Rewrite Pluralize
    module TextHelper
      
      # if parameters are symbols that read from translations
      def pluralize_with_localize_ext(count, singular, plural = nil)
        # Default value for plural if singular is symbol
        plural = singular if not singular.nil? and singular.is_a?(Symbol) and plural.nil?
        # strings from symbols
        singular = LocalizeExt::Helper.translate_caller(caller[0], "translations", singular, nil, singular.to_s) if not singular.nil? and singular.is_a?(Symbol)
        if not plural.nil? and plural.is_a?(Symbol)
          plural_key = plural
          plural_key = LocalizeExt::LanguageRules.plural_key(count, plural_key)
          plural = LocalizeExt::Helper.translate_caller(caller[0], "plurals", plural_key, nil, plural.to_s)   
        end
        
        # default pluralize
        pluralize_without_localize_ext(count, singular, plural)
      end
      alias_method_chain :pluralize, :localize_ext
    end
    # distance_of_time_in_words  rewrite
    module DateHelper
     private
     def translate_with_localize_ext(key, default, count = nil)
        plural_key = key
        plural_key = LocalizeExt::LanguageRules.plural_key(count, plural_key) unless count.nil?
        translation = LocalizeExt::Helper.translate_caller(nil, "translations", plural_key, nil, nil) if plural_key != key
        translation = LocalizeExt::Helper.translate_caller(nil, "translations", key, nil, default) if translation.nil?
        translation = translation % [count] unless count.nil?
        translation
     end
     
     def distance_of_time_in_words(from_time, to_time = 0, include_seconds = false)
        from_time = from_time.to_time if from_time.respond_to?(:to_time)
        to_time = to_time.to_time if to_time.respond_to?(:to_time)
        distance_in_minutes = (((to_time - from_time).abs)/60).round
        distance_in_seconds = ((to_time - from_time).abs).round

        case distance_in_minutes
          when 0..1
            return (distance_in_minutes == 0) ? translate_with_localize_ext(:less_than_minute, 'less than a minute') : translate_with_localize_ext(:one_minute, '1 minute') unless include_seconds
            case distance_in_seconds
              when 0..4   then translate_with_localize_ext(:less_than_n_seconds, 'less than %d seconds', 5)
              when 5..9   then translate_with_localize_ext(:less_than_n_seconds, 'less than %d seconds', 10)
              when 10..19 then translate_with_localize_ext(:less_than_n_seconds, 'less than %d seconds', 20)
              when 20..39 then translate_with_localize_ext(:half_minute, 'half a minute')
              when 40..59 then translate_with_localize_ext(:less_than_minute, 'less than a minute')
              else             translate_with_localize_ext(:one_minute, '1 minute')
            end

          when 2..44           then translate_with_localize_ext(:n_minutes, '%d minutes', distance_in_minutes)
          when 45..89          then translate_with_localize_ext(:about_hour, 'about 1 hour')
          when 90..1439        then translate_with_localize_ext(:about_n_hours, 'about %d hours', (distance_in_minutes.to_f / 60.0).round) 
          when 1440..2879      then translate_with_localize_ext(:one_day, '1 day')
          when 2880..43199     then translate_with_localize_ext(:n_days, '%d days', (distance_in_minutes / 1440).round)
          when 43200..86399    then translate_with_localize_ext(:about_month, 'about 1 month')
          when 86400..525599   then translate_with_localize_ext(:n_month, '%d months', (distance_in_minutes / 43200).round)
          when 525600..1051199 then translate_with_localize_ext(:one_year, 'about 1 year')
          else                      translate_with_localize_ext(:over_n_years, 'over %d years', (distance_in_minutes / 525600).round)
        end
      end
    end
  end
end