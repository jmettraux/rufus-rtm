

require 'lib/rufus/rtm/base.rb'

require 'rubygems'
require 'rake'


#
# CLEAN

require 'rake/clean'
CLEAN.include('pkg', 'tmp', 'html')
task :default => [ :clean ]


#
# GEM

require 'jeweler'

Jeweler::Tasks.new do |gem|

  gem.version = Rufus::RTM::VERSION
  gem.name = 'rufus-rtm'
  gem.summary = 'yet another RememberTheMilk wrapper'

  gem.description = %{
    yet another RememberTheMilk wrapper
  }
  gem.email = 'jmettraux@gmail.com'
  gem.homepage = 'http://github.com/jmettraux/rufus-rtm/'
  gem.authors = [ 'John Mettraux' ]
  gem.rubyforge_project = 'rufus'

  gem.test_file = 'test/test.rb'

  gem.add_dependency 'rufus-verbs', '>= 1.0.0'
  gem.add_development_dependency 'yard', '>= 0'

  # gemspec spec : http://www.rubygems.org/read/chapter/20
end
Jeweler::GemcutterTasks.new


#
# DOC

begin

  require 'yard'

  YARD::Rake::YardocTask.new do |doc|
    doc.options = [
      '-o', 'html/rufus-rtm', '--title',
      "rufus-rtm #{Rufus::RTM::VERSION}"
    ]
  end

rescue LoadError

  task :yard do
    abort "YARD is not available : sudo gem install yard"
  end
end


#
# TO THE WEB

task :upload_website => [ :clean, :yard ] do

  account = 'jmettraux@rubyforge.org'
  webdir = '/var/www/gforge-projects/rufus'

  sh "rsync -azv -e ssh html/rufus-rtm #{account}:#{webdir}/"
end

