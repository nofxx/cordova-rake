#
# Rake / Cordova
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

task default: [:greet, 'compile:all', :replace, :report]

task :greet do
  puts "PhoneGap Rake! #{environment} #{ENV['CORDOVA_PLATFORMS']}"
  puts "---"
end

desc 'Setup env for development'
task :setup do
  sh 'npm -g install phonegap cordova coffee-script'
  sh 'gem install haml sass yamg'
end

task :report do
  puts "---"
  puts "Rake done! #{format("%.2f", Time.now - START)}s"
end

desc 'Replace ENV variables on www/js'
task :replace do
  data = YAML.load_file('config/app.yml')[environment]
  [:js, :css, :html].map { |f| get_sources(f, 'www/js') }.flatten.each do |f|
    data.each do |k, v|
      sh "sed -i \"s/'...#{k.upcase}...'/'#{v}'/g\" #{f}"
      # sh "sed -i \"s/'####{k.upcase}###'/#{v}/g\" #{f}" # numbers
    end
  end
end

namespace :compile do

  desc 'Compiles all resources'
  task :all => [:js, :css, :html]

  desc 'Compiles Coffeescript -> Javascript'
  task :js => get_sources(:coffee).ext('.js')

  desc 'Compiles SASS -> CSS'
  task :css => get_sources(:sass).ext('.css')

  desc 'Compiles HAML -> HTML'
  task :html => get_sources(:haml).ext('.html')

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
    # print "HAML | #{t.source} -> #{t.name} | "
    # sh "haml #{t.source} #{}"
  end
end

namespace :release do

  task :check_keys_dir do
    FileUtils.mkdir '.keys' unless File.exist?('.keys')
  end

  desc 'Deploy to Google Play Store'
  task google: ['check_keys_dir', 'google:keygen', 'google:sign', 'google:zipalign']

  desc 'Deploy to Apple App Store'
  task apple: ['apple:key']

  namespace :google do


    desc 'Generates Google Play Store .keystore'
    task :keygen do
      if File.exist?('.keys/google.keystore')
        puts 'Key found'
      else
        puts "\nGenerate key first!\n\n"
        c = "keytool -genkey -v -keystore ./.keys/google.keystore "\
            "-alias #{config(:app)} -keyalg RSA -keysize 2048 -validity 10000"
        puts c
        exec c
      end
    end

    task :sign do
      c = "jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 "\
          "-keystore google.keystore #{config(:app)}-release-unsigned.apk "\
          "#{config(:app)}"
      puts c
      system c
    end

    task :zipalign do
      c = "zipalign -v 4 #{config(:app)}-release-unsigned.apk "\
          "#{config(:app)}.apk"
      puts c
      system c
    end
  end

  namespace :apple do

  end
end
