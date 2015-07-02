require 'rake'
require 'yaml'
require 'tilt'
require 'nokogiri'
START = Time.now

#
# Some helper methods
#
def get_sources(ext, dir = 'app')
  source_files = Rake::FileList.new("#{dir}/**/*.#{ext}") do |fl|
    fl.exclude("~*")
    fl.exclude(/^scratch\//)
    # fl.exclude { |f| `git ls-files #{f}`.empty? } # Only commited
  end
end

def environment
  ENV['TARGET'] || 'development'
end

def config(key)
  return @xml[key] if @xml
  xml = Nokogiri::XML(File.open('config.xml'))
  @xml = {
    app: xml.xpath("//xmlns:name").text,
    desc: xml.xpath("//xmlns:description").text,
    platforms: xml.xpath("//xmlns:platform").map { |os| os['name'] }
  }
  config(key)
end

def layout
  @layout ||= Tilt.new('app/html/layout.haml')
end

def app
  config(:app)
end

# And load all tasks
tasks = File.join(File.dirname(__FILE__), '..', 'tasks')
Dir.glob("#{tasks}/*.rake").each { |r| import r }
