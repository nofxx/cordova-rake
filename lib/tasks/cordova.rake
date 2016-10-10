#
# Rake / Cordova
#
task default: [:compile]

def find_or_create_file(name)
  if File.exist?(name)
    print Paint["#{name} already exists! Overwrite? [y/N] ", :red]
    return unless STDIN.gets.chomp == 'y'
  end
  puts "Creating #{name}..."
  FileUtils.cp(File.join(__dir__, '..', 'templates', name), '.')
end

task :greet do
  puts Paint["Cordova Rake [#{env}] #{ENV['CORDOVA_PLATFORMS']}", :red]
  puts Paint['        ----', :red]
end

desc 'Setup env for development'
task :setup do
  puts Paint['Installing NPM stuff...', :blue]
  sh 'npm -g install phonegap cordova coffee-script '
  sh 'npm -g install ios-deploy ios-sim ' if RUBY_PLATFORM =~ /darwin/
  puts Paint['Installing GEM stuff...', :red]
  find_or_create_file 'Gemfile'
  sh 'bundle update'
end

task :report do
  puts Paint['----', :red]
  puts Paint["Rake done! #{format('%.2f', Time.now - START)}s", :black]
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
  find_or_create_file('Guardfile')
end

namespace :emulate do
  desc 'Run on Android emulator'
  task :android do
    sh 'cordova build android'
    sh "cordova emulate android --target #{ARGV[1]}"
  end
  task android: :compile

  desc 'Run on iOS emulator'
  task :ios do
    sh 'cordova build ios'
    sh 'cordova emulate ios'
  end
  task ios: :compile
end

namespace :run do
  desc 'Run on Android device or emulator'
  task :android do
    sh 'cordova build android'
    sh 'cordova run android'
  end
  task android: :compile

  desc 'Run on iOS plugged device or emulator'
  task :ios do
    sh 'cordova build ios'
    sh 'cordova run ios --device'
  end
  task ios: :compile
end
