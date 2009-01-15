module LocalizeExt
  class Generator
    class << self
      cattr_accessor :logger
      # Generate translations
      def generate
        prepare
        with_each_file_in(RAILS_ROOT + '/app') do |f|
          hash = get_file_translations(f)
          merge(f, hash, false)
        end
        finish
      end
      # Compare existing and find missing translations
      def compare
        prepare
        with_each_file_in(RAILS_ROOT + '/app') do |f|
          hash = get_file_translations(f)
          merge(f, hash, true)
        end
        finish
      end
      
      private
      # start language helper
      def prepare
        language = ENV['language'] || LocalizeExt.default_language
        self.logger = Logger.new("#{RAILS_ROOT}/log/language_#{language}.log") 
        LocalizeExt::Helper.start(language)
      end
      # cleanup
      def finish
        self.logger.close
      end
      # Move recursively in the directories
      def with_each_file_in(path, &proc)
        return if path == (RAILS_ROOT + LocalizeExt.localize_root)
        return if File.basename(path)[0] == 46 #dot
        Pathname.new(path).children(true).each do |file|
          file_name = file.to_s
          if File.file?(file_name)
            proc.call(file_name) 
          else
            with_each_file_in(file_name, &proc)
          end
        end
      end
      # Generate file translations
      def get_file_translations(file_name)
        text = File.new(file_name).read
        
        yaml_hash = {}
        yaml_hash["translations"] = {}
        yaml_hash["plurals"] = {}
        
        match_strings(text, yaml_hash)
        match_symbols(text, yaml_hash)
        match_pluralize(text, yaml_hash)
        
        yaml_hash
      end
      # merge hashes
      def merge(file_name, hash, log_only)
        language = LocalizeExt::Helper.current_language
        language_file = LocalizeExt::Helper.localized_path(file_name, language) + ".yml"
        
        unless hash["translations"].empty? && hash["plurals"].empty?
          log('Translation file is missing: %s' %[relative_path(language_file)]) if !FileTest.exists?(language_file) && log_only
          
          base_yaml = LocalizeExt::Helper.translations(RAILS_ROOT, language)
          yaml = LocalizeExt::Helper.load_language_file(language_file)
          
          ["translations", "plurals"].each do |group|
            unless hash[group].empty?
              hash[group] = merge_group(file_name, group, hash[group], yaml[group], base_yaml[group]) 
            else
              log('Group [%s] is not used in %s' % [group, relative_path(file_name)]) unless yaml[group].nil? || yaml[group].empty?
            end
          end
        end
        hash.delete_if{|key, value| value.nil? || value.empty?}  
        LocalizeExt::Helper.save_language_file(language_file, hash) unless log_only || hash.empty?
      end
      #merge group in hashes
      def merge_group(file_name, group, hash, yaml, base_yaml)
        yaml ||= {}
        base_yaml ||= {}
        
        #remove non used
        keys_to_delete = []
        yaml.each_key do |key|
          unless hash.has_key?(key)
            log '[%s/%s] is not used in %s' % [group, key, relative_path(file_name)]
            keys_to_delete.push(key)
          end
        end
        yaml.delete_if {|key, value| keys_to_delete.include?(key)}
        # Update missing values
        hash.each_pair do |key, value|
           unless yaml.has_key?(key) || base_yaml.has_key?(key)
            log "[%s/%s] missing in %s" % [group, key, relative_path(file_name)]
            yaml[key] = value
          end
        end
        yaml
      end
      #get relative path
      def relative_path(path)
        return ""  unless path.starts_with?(RAILS_ROOT + '/app/')
        path[RAILS_ROOT.length + 4, path.length]
      end
      # Log info to screen and file
      def log(info)
        #p info
        self.logger.info("Language: " + info)
      end
      # Match strings from file
      def match_strings(text, yaml_hash)
        #Strings
        text.gsub(/"(([^"\\]|\\.)*)"\[:([A-Za-z0-9_]+)\]/) do |m|
          yaml_hash["translations"][$3.to_sym] = $1
        end
        text.gsub(/'(([^'\\]|\\.)*)'\[:([A-Za-z0-9_]+)\]/) do |m|
          yaml_hash["translations"][$3.to_sym] = $1
        end
      end
      # Match symbols from file
      def match_symbols(text, yaml_hash)
        text.gsub(/:([A-Za-z0-9_]+)\.t/) do |m|
          yaml_hash["translations"][$1.to_sym] = $1
        end
        text.gsub(/:([A-Za-z0-9_]+)\["(([^"\\]|\\.)*)"\]/) do |m|
          yaml_hash["translations"][$1.to_sym] = $2
        end
        text.gsub(/:([A-Za-z0-9_]+)\['(([^'\\]|\\.)*)'\]/) do |m|
          yaml_hash["translations"][$1.to_sym] = $2
        end
      end
      # Match pluralize
      def match_pluralize(text, yaml_hash)
        regex = /pluralize\s*\(\s*[^,]+\s*(?:,\s*([^,]+|"(?:[^"\\]|\\.)*"|'(?:[^'\\]|\\.)*')\s*)(?:,\s*([^,]+|"(?:[^"\\]|\\.)*"|'(?:[^'\\]|\\.)*')\s*)?\)/
        sym_regex = /:([A-Za-z0-9_]+)/
        text.gsub(regex) do |m|
          singular = $1
          plural = $2
          plural = singular if plural.nil?
          
          unless singular.nil? || (singular =~ sym_regex).nil? 
            yaml_hash["translations"][$1.to_sym] = $1  
          end
          
          unless plural.nil? || (plural =~ sym_regex).nil? 
            yaml_hash["plurals"][$1.to_sym] = $1  
          end
        end
      end
    end
  end  
end
