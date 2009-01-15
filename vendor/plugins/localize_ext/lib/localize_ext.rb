require 'yaml'
require 'dispatcher'
require 'ext/core_ext.rb'
require 'ext/action_view.rb'
require 'ext/active_record.rb'
module LocalizeExt
  @@enable_auto_create = false
  @@default_language = 'en-US'
  @@localize_root = '/app/localize'
  # get localize root
  def self.localize_root
    @@localize_root
  end
  # set localize root
  def self.localize_root=(value)
    @@localize_root = value
  end
  # get property identifing that files with translation should be automatically created during access 
  # and values requested should be written
  def self.enable_auto_create
    @@enable_auto_create
  end
  # set property identifing that files with translation should be automatically created during access 
  # and values requested should be written
  def self.enable_auto_create=(value)
    @@enable_auto_create = value
  end
  # get default language
  def self.default_language
    @@default_language
  end
  # set default language
  def self.default_language=(value)
    @@default_language = value
  end
  
	class Helper
		attr_accessor :translations_cache, :current_language, :logger, :enable_auto_create
		
		def initialize(language)
			self.translations_cache = {}
			self.current_language = language
			self.logger = Logger.new("#{RAILS_ROOT}/log/language_#{language}.log") 
      self.enable_auto_create = LocalizeExt.enable_auto_create #(RAILS_ENV == 'development')
		end
		
		class << self
			cattr_accessor :instance
			def current_language
				return instance.current_language if instance
				return nil
			end
			#start
      def start(language)
				language ||=  LocalizeExt.default_language
				self.instance = Helper.new(language)
        LocalizeExt::LanguageRules.start(language)
				LocalizeExt::TimeFormat.start(language)
		  end
      #get app relative path
			def app_relative_path(path)
				#raise StandardError.new('path is invalid :' + path) unless path.starts_with?(RAILS_ROOT)
				return ""  unless path.starts_with?(RAILS_ROOT + '/app/')
				path[RAILS_ROOT.length + 4, path.length]
			end
			# Get localized path for given path and language
			def localized_path(path, language = nil)
        return path if current_language.nil?
				return path unless path.starts_with?(RAILS_ROOT)
				RAILS_ROOT + LocalizeExt.localize_root + "/#{language || current_language}%s" % [app_relative_path(path)] 
		  end
     
      #Create default empty language file
			def save_language_file(path, object)
				directory_name = File.dirname(path)
        FileUtils.mkpath(directory_name) unless File.exists?(directory_name)
				File.open(path, 'w' ) do |out|
					YAML.dump(object, out )
				end
				object
		  end
      #load language file
      def load_language_file(path)
        return {} unless File.exists?(path)
        YAML.load_file(path) || {}
      end
			# Get translation for path
			def translations(path, language)
				language_file = localized_path(path, language) + ".yml"
        instance.translations_cache[language_file] ||= load_language_file(language_file)
			end
			#translate by given key
			def translate_caller(caller_file, group, key, language = nil, default = nil)
        return key.to_s if current_language.nil?   
				if caller_file.nil?
					original_path = RAILS_ROOT 
				else
					s = caller_file.scan(/^(.+)\:(\d+)(:in `[_\w\d]+')?$/)
					original_path = s.length > 0 ? s[0][0] : RAILS_ROOT	
			  end
        group_hash = translations(original_path, language).fetch(group) do |_group|
					localized_path = localized_path(original_path, language)
					# if this is local file hash - then we should check global for existing key, otherwise create local file
					if localized_path(RAILS_ROOT, language) != localized_path
						value = translations(RAILS_ROOT, language).fetch(group, {})[key]
            return value unless value.nil?
					end
					localized_path += ".yml"
					# this code is running when there is no local file or group in local file and there is no such group/key pair in global file
					# we should create file with default information
					# or add the group to existing file
					instance.logger.info('Language: "%s/%s" missing in %s.' % [group, key, caller_file])
          return default if (!self.instance.enable_auto_create || default.nil?)
          value = {group=>{key=>default}}
          value.merge!(load_language_file(localized_path)) if File.exists?(localized_path)
          result = value
          if self.instance.enable_auto_create
            instance.logger.info('Generating "%s"' % [localized_path])
            result = save_language_file(localized_path, value)[group] || {}   
          end
          result
				end
        group_hash ||= {}
        group_hash.fetch(key) do |_key|
					# this code is running after group is ensured as created and key not exists
					# we must load language and add key
					instance.logger.info('Language: "%s/%s" missing in %s.' % [group, key, caller_file])
          if self.instance.enable_auto_create 
            localized_path = localized_path(original_path, language) + ".yml"
            
            value = load_language_file(localized_path)
            group_hash[key] = default 
            value[group] = group_hash
            
            instance.logger.info('Generating "%s"' % [localized_path])
            save_language_file(localized_path, value)   
          end
					default
				end
			end
		end
  end
  
  module LanguageRules
    module Extensions
      
    end
    private
    @@current_extension = nil
    #start language rules helper
    def self.start(language)
      class_name = language.upcase().gsub('-', '_');
      file_name = File.join(File.dirname(__FILE__), 'ext/%s/extensions.rb' % [language]) 
      @@current_extension = nil
      
      if not LocalizeExt::LanguageRules::Extensions.constants.include?(class_name) and FileTest.exist?(file_name)
        require file_name
      end
      
      if LocalizeExt::LanguageRules::Extensions.constants.include?(class_name)
        @@current_extension = LocalizeExt::LanguageRules::Extensions.const_get(class_name) 
      end
    end
    
    #get plural key
    def self.plural_key(count, key)
      return key if @@current_extension.nil?
      @@current_extension.plural_key(count, key)
    end
  end
end

