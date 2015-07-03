desc 'Compiles all resources'
task :compile => [:greet, 'compile:all', :report]
desc 'Compiles all resources with ENV=production'
task :release => [:set_release, :compile]

task :set_release do
  @env = 'production'
end

namespace :compile do
  task :all   => [:js, :css, :html, :vars]

  desc 'Compiles Coffee -> JS'
  task :js => get_sources(:coffee).ext('.js')

  desc 'Compiles SASS -> CSS'
  task :css => get_sources(:sass).ext('.css')

  desc 'Compiles HAML -> HTML'
  task :html => get_sources(:haml).ext('.html')

  desc 'Postcompile ENV variables'
  task :vars do
    data = YAML.load_file('config/app.yml')[env]
    [:js, :css, :html].map { |f| get_sources(f, 'www/js') }.flatten.each do |f|
      data.each do |k, v|
        sh "sed -i \"s/'...#{k.upcase}...'/'#{v}'/g\" #{f}"
        # sh "sed -i \"s/'####{k.upcase}###'/#{v}/g\" #{f}" # numbers
      end
    end
  end

  rule '.js' => '.coffee' do |t|
    output = File.dirname(t.source).gsub(/app\//, 'www/')
    # print "CoffeeScript | " # #{t.source} -> #{output}"
    sh "coffee --no-header -b -o #{output} #{t.source}"
  end

  rule '.css' => '.sass' do |t|
    # print "SASS | #{t.source} -> #{t.name} | "
    sh "sass #{t.source} #{t.name.gsub(/app\//, 'www/')}"
  end

  rule '.html' => '.haml' do |t|
    next if t.name =~ /layout/
    template = Tilt.new(t.source)
    # => #<Tilt::HAMLTemplate @file="path/to/file.haml" ...>
    File.open(t.name.gsub(/app\//, 'www/'), 'w') do |f|
      f.puts layout.render { template.render }
    end
    puts "haml #{t.source} -> #{t.name}"
  end
end
