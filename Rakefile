begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "shawty-server"
    gem.summary = %Q{Ultra-lightweight url shortening server for Heroku.com}
    gem.description = %Q{Run your own url shortener add your own web address for free on Heroku.com}
    gem.email = "gitcommit@6brand.com"
    gem.homepage = "http://github.com/JackDanger/shawty-server"
    gem.authors = ["Jack Danger Canty"]
    gem.add_dependency "alphadecimal", ">= 1.0.1"
    gem.add_development_dependency "active_record", ">= 0"
    gem.add_development_dependency "shoulda", ">= 0"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end



task :default => :test

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << '.'
  test.pattern = 'test.rb'
  test.verbose = true
end
