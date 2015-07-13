#
# Rake / Cordova
#

task default: [:compile]

task :greet do
  puts Paint["Cordova Rake [#{env}] #{ENV['CORDOVA_PLATFORMS']}", :red]
  puts Paint["        ----", :red]
end

desc 'Setup env for development'
task :setup do
  sh 'npm -g install phonegap cordova coffee-script '
  sh 'npm -g install ios-deploy ios-sim ' if RUBY_PLATFORM =~ /darwin/
  sh 'gem install haml sass yamg guard guard-coffeelint'
end

task :report do
  puts Paint["----", :red]
  puts Paint["Rake done! #{format("%.2f", Time.now - START)}s", :black]
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

desc 'Prepare & Ripple emulate'
task :guard do
  if File.exists?('Guardfile')
    puts "Guardfile exists"
  else
    puts "Creating Guardfile"
    FileUtils.cp(File.join(__FILE__, '..', 'templates', 'Guardfile'), '.')
  end
end

namespace :emulate do
  desc 'Run on Android emulator'
  task :android do
    sh 'cordova build android'
    sh "cordova emulate android --target #{ARGV[1]}"
  end

  desc 'Run on iOS emulator'
  task :ios do
    sh 'cordova build ios'
    sh 'cordova emulate ios'
  end
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
