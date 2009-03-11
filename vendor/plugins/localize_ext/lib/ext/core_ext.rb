require 'date'
require 'time'
class Symbol
   @lz_default
   @lz_caller
   
   def t
     key = self
     LocalizeExt::Helper.translate_caller(caller[0], "translations", key, nil, key.to_s)
   end

   def [](default)
     @lz_default = default
     @lz_caller = caller[0]
     self
   end
   
   def %(*arguments)
     return self.lz_to_s % arguments if @lz_caller.nil?
     translate_internal % arguments
   end
   
   def to_s_with_localize_ext
     return to_s_without_localize_ext if @lz_caller.nil?
     translate_internal
   end
   alias_method_chain :to_s, :localize_ext

   def is_localized_symbol?
     !@lz_caller.nil?
   end

   private
   def translate_internal
     key = self
     #avoid recursion when calling not own methods
     lz_caller, lz_default= @lz_caller, @lz_default
     @lz_caller, @lz_default = nil, nil
     
     result = LocalizeExt::Helper.translate_caller(lz_caller, "translations", key, nil, lz_default)
     
     @lz_caller, @lz_default= lz_caller, lz_default
     result
   end
end

class String
  alias_method :square_brackets_without_localize_ext, :[]
  alias_method :plus_without_localize_ext, :+
  
  def [](*arguments)
    if arguments[0].is_a?(Symbol)
      language = arguments.length > 1 ? arguments[1] : nil
      LocalizeExt::Helper.translate_caller(caller[0], "translations", arguments[0], language, self)
    else
      square_brackets_without_localize_ext(*arguments)  
    end
  end
  
  def +(value)
    return plus_without_localize_ext(value.to_s) if value.is_a?(Symbol) && value.is_localized_symbol?
    plus_without_localize_ext(value) 
  end
  
end

module LocalizeExt
  module TimeFormat
    private
    L_MONTHNAMES = "January February March April May June July August September October November December"
    L_DAYNAMES = "Sunday Monday Tuesday Wednesday Thursday Friday Saturday"
    L_ABBR_MONTHNAMES = "Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec"
    L_ABBR_DAYNAMES = "Sun Mon Tue Wed Thu Fri Sat"
    
    @@translate_cache = {}
    public
    def self.start(language)
      hash = {
        :MONTHNAMES => LocalizeExt::Helper.translate_caller(nil, "time", :MONTHNAMES, language, L_MONTHNAMES),
        :DAYNAMES => LocalizeExt::Helper.translate_caller(nil, "time", :DAYNAMES, language, L_DAYNAMES),
        :ABBR_MONTHNAMES => LocalizeExt::Helper.translate_caller(nil, "time", :ABBR_MONTHNAMES, language, L_ABBR_MONTHNAMES),
        :ABBR_DAYNAMES => LocalizeExt::Helper.translate_caller(nil, "time", :ABBR_DAYNAMES, language, L_ABBR_DAYNAMES)
      }
      hash.each {|key, value| 
        @@translate_cache[key] = eval("%w(" + value +")") 
      }
    end
    
    def self.translate_with_localize_ext(group, index)
      return @@translate_cache[group][index]
    end
    
    def self.has_translation?()
      return !@@translate_cache.empty?
    end
  end
end 

class Time
  def emit(e, f) # :nodoc:
    case e
    when Numeric
      sign = %w(+ + -)[e <=> 0]
      e = e.abs
    end

    s = e.to_s

    if f[:s] && f[:p] == '0'
      f[:w] -= 1
    end

    if f[:s] && f[:p] == "\s"
      s[0,0] = sign
    end

    if f[:p] != '-'
      s = s.rjust(f[:w], f[:p])
    end

    if f[:s] && f[:p] != "\s"
      s[0,0] = sign
    end

    s = s.upcase if f[:u]
    s = s.downcase if f[:d]
    s
  end

  def emit_ad(e, w, f) # :nodoc:
    if f[:x]
      f[:u] = true
      f[:d] = false
    end
    f[:p] ||= "\s"
    f[:w] = [f[:w], w].compact.max
    emit(e, f)
  end
  private :emit, :emit_ad
  
  include LocalizeExt::TimeFormat
  #alias_method :lz_strftime, :strftime
  def strftime_with_localize_ext(fmt)
   return strftime_without_localize_ext(fmt) unless LocalizeExt::TimeFormat.has_translation? 
   fmt.gsub(/%([-_0^#]+)?(\d+)?[EO]?(:{1,3}z|.)/m) do |m|
      f = {}
      s, w, c = $1, $2, $3
      if ['A', 'a', 'B', 'b'].include?(c)
        case c
          when 'A'; emit_ad(LocalizeExt::TimeFormat.translate_with_localize_ext(:DAYNAMES, wday), 0, f)
          when 'a'; emit_ad(LocalizeExt::TimeFormat.translate_with_localize_ext(:ABBR_DAYNAMES, wday), 0, f)
          when 'B'; emit_ad(LocalizeExt::TimeFormat.translate_with_localize_ext(:MONTHNAMES, mon - 1), 0, f)
          when 'b'; emit_ad(LocalizeExt::TimeFormat.translate_with_localize_ext(:ABBR_MONTHNAMES, mon - 1), 0, f)
        end
      else
        emit_ad(strftime_without_localize_ext(m), 0, f)
      end
    end
  end
  alias_method_chain :strftime, :localize_ext
end

