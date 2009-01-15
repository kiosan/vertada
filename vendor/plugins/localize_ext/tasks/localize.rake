namespace :localize_ext do
  desc 'Generate translations'
  task :generate=>:environment do |t, args|
    require File.join(File.dirname(__FILE__), '../lib/generator.rb')
    LocalizeExt::Generator.generate
  end
  
  desc 'Display and log missing and not used translations'
  task :compare=>:environment do |t, args|
    require File.join(File.dirname(__FILE__), '../lib/generator.rb')
    LocalizeExt::Generator.compare
  end
end