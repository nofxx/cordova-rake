desc 'Compiles all resources'
task compile: [:greet, 'compile:all', :report]
desc 'Compiles all resources with ENV=production'
task release: [:set_release, :compile]

task :set_release do
  @env = 'production'
end

# ERB render wrapper
class Erbs < OpenStruct
  def render(template)
    ERB.new(template).result(binding)
  end
end

CONFIG_YML = 'config/app.yml'.freeze

namespace :compile do
  task all: [:js, :css, :html, :vars]

  desc 'Compiles Coffee -> JS'
  task js: get_sources(:coffee).ext('.js')

  desc 'Compiles SASS -> CSS'
  task css: get_sources(:sass).ext('.css')

  desc 'Compiles HAML -> HTML'
  task html: get_sources(:haml).ext('.html')

  desc 'Compiles SLIM -> HTML'
  task html: get_sources(:slim).ext('.html')

  desc 'Postcompile ENV variables'
  task :vars do
    next unless File.exist?(CONFIG_YML)
    data = YAML.load_file(CONFIG_YML)[env]
    # STDOUT.puts 'ERB.new(CONFIG_YML).render on www/'
    [:js, :css, :html].map { |f| get_sources(f, 'www') }.flatten.each do |file|
      out = Erbs.new(data).render(File.read(file))
      File.open(file, 'w') { |f| f << out }
    end
  end

  rule '.js' => '.coffee' do |t|
    output = File.dirname(t.source).gsub(%r{app/}, 'www/')
    # print "CoffeeScript | " # #{t.source} -> #{output}"
    sh "coffee --no-header -b -o #{output} #{t.source}"
  end

  rule '.css' => '.sass' do |t|
    # print "SASS | #{t.source} -> #{t.name} | "
    out = t.name.gsub(%r{app/}, 'www/')
    sh "sass #{t.source} #{out}"
  end

  rule '.html' => '.haml' do |t|
    next if t.name =~ /layout/
    template = Tilt.new(t.source)
    # => #<Tilt::HAMLTemplate @file="path/to/file.haml" ...>

    File.open(t.name.gsub(%r{app/}, 'www/'), 'w') do |f|
      f.puts layout.render { template.render }
    end
    STDOUT.puts "haml #{t.source} -> #{t.name}"
  end

  rule '.html' => '.slim' do |t|
    next if t.name =~ /layout/
    template = Tilt.new(t.source)

    File.open(t.name.gsub(%r{app/}, 'www/'), 'w') do |f|
      f.puts layout.render { template.render }
    end
    STDOUT.puts "slim #{t.source} -> #{t.name}"
  end
end
