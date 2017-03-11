require 'rake'
require 'yaml'
require 'tilt'
require 'paint'
require 'nokogiri'
require 'erb'

START = Time.now

#
# Some helper methods
#
def get_sources(ext, dir = 'app')
  Rake::FileList.new("#{dir}/**/*.#{ext}") do |fl|
    fl.exclude('~*')
    fl.exclude(%r{^scratch/})
    # fl.exclude { |f| `git ls-files #{f}`.empty? } # Only commited
  end
end

def config(key)
  return @xml[key] if @xml
  xml = Nokogiri::XML(File.open('config.xml'))
  @xml = {
    app: xml.xpath('//xmlns:name').text,
    desc: xml.xpath('//xmlns:description').text,
    platforms: xml.xpath('//xmlns:platform').map { |os| os['name'] }
  }
  config(key)
end

def layout
  @layout ||= Tilt.new(Dir['app/html/layout.*'].first)
end

def app
  config(:app)
end

def env
  @env ||= ENV['TARGET'] || 'development'
end

# And load all tasks
tasks = File.join(File.dirname(__FILE__), '..', 'tasks')
Dir.glob("#{tasks}/*.rake").each { |r| import r }
