#
# Rake / Cordova
#

task default: [:greet, :compile, :report]

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

desc 'Phonegap Dev App, optional: port.'
task :serve do
  port = ARGV.last.to_i
  port = 4000 if port.zero?
  sh "phonegap serve -p #{port}"
end

desc 'Prepare & Ripple emulate'
task :ripple do
  sh 'cordova prepare'
  sh 'ripple emulate'
end

namespace :run do
desc 'Run on Android device or emulator'
task :android do
  sh 'cordova build android'
  sh 'cordova run android'
end

desc 'Run on iOS plugged device or emulator'
task :ios do
  sh 'cordova build ios'
  sh 'cordova run ios --device'
end
end

desc 'Compiles all resources'
task :compile   => ['compile:all']

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
    data = YAML.load_file('config/app.yml')[environment]
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
    # print "HAML | #{t.source} -> #{t.name} | "
    # sh "haml #{t.source} #{}"
  end
end

#
#
# RELEASE
#
#
namespace :release do

  task :check_dirs do
    %w( .keys build ).each do |dir|
      FileUtils.mkdir dir unless File.exist?(dir)
    end
  end

  desc 'Deploy to Google’s Play Store'
  task google: [:check_dirs,  'google:all', :report]

  namespace :google do
    task :all   => [:clean, :keygen, :archive, :sign, :align, :check, :submit]

    # desc 'Clean up build folder from apks'
    task :clean do
      Dir['build/*.apk'].each { |f| File.delete(f) }
    end

    # desc 'Generates Google Play Store .keystore'
    task :keygen do
      next if File.exist?('.keys/google.keystore')
      puts "\nGenerate key first!\n\n"
      sh "keytool -genkey -v -keystore ./.keys/google.keystore "\
         "-alias #{app} -keyalg RSA -keysize 2048 -validity 10000"
    end

    task :archive do
      sh 'cordova build --release android'
      FileUtils.cp 'platforms/android/build/outputs'\
                   '/apk/android-release-unsigned.apk',
                   "build/#{app}-unsigned.apk"
    end

    task :sign do
      sh "jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 "\
         "-keystore ./.keys/google.keystore build/#{app}-unsigned.apk "\
         "#{app}"
      FileUtils.cp "build/#{app}-unsigned.apk", "build/#{app}-signed.apk"
    end

    task :align do
      sh "zipalign -f -v 4 build/#{app}-signed.apk build/#{app}.apk"
    end

    task :check do
      arch = "build/#{app}.apk"
      if File.exists? arch
        puts "Build done! #{arch} #{File.size(arch).to_f/(1024 * 1024)} Mb"
      else
        puts "Something BAD! No #{arch}!"
        exit 1
      end
    end

    task :submit do
      #hope we can soon
    end
  end

  #
  # Apple
  #
  desc 'Deploy to Apple’s App Store'
  task apple: [:check_keys_dir, 'apple:all', :report]

  namespace :apple do
    task :all   => [:archive, :upload, :check]

  end
end
