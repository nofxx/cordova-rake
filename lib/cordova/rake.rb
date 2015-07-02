require 'rake'
require 'yaml'
require 'tilt'
require 'nokogiri'
START = Time.now

# Just load all tasks
tasks = File.join(File.dirname(__FILE__), '..', 'tasks')
Dir.glob("#{tasks}/*.rake").each { |r| import r }
