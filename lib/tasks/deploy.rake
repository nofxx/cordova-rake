#
#
# Deploy!
#
#
def check_file(file)
  if File.exist? file
    file_size = File.size(file).to_f / (1024 * 1024)
    puts Paint["---\nRelease build ok: #{file} #{file_size} MB", :green]
  else
    puts Paint["Something BAD! No #{file}!", :red]
    exit 1
  end
end

namespace :release do
  # Make sure we have some dirs
  task :check_dirs do
    %w(.keys build).each do |dir|
      FileUtils.mkdir dir unless File.exist?(dir)
    end
  end

  desc 'Deploy to Google’s Play Store'
  task google: [:release, :check_dirs, 'google:all', :report]

  namespace :google do
    task all: [:clean, :keygen, :archive, :sign, :align, :check, :submit]

    # desc 'Clean up build folder from apks'
    task :clean do
      Dir['build/*.apk'].each { |f| File.delete(f) }
    end

    # desc 'Generates Google Play Store .keystore'
    task :keygen do
      next if File.exist?('.keys/google.keystore')
      puts Paint["\nGenerate key first!\n\n", :red]
      sh 'keytool -genkey -v -keystore ./.keys/google.keystore '\
         "-alias '#{app}' -keyalg RSA -keysize 2048 -validity 10000"
    end

    task :archive do
      sh ' cordova build --release android'
      FileUtils.cp 'platforms/android/app/build/outputs'\
                   '/apk/release/app-release-unsigned.apk',
                   "build/#{app}-unsigned.apk"
    end

    task :sign do
      key = ENV['GOOGLE_KEY']
      key = GOOGLE_KEY if Object.const_defined?(:GOOGLE_KEY)
      comm = ' jarsigner -verbose -sigalg SHA1withRSA '\
             '-digestalg SHA1 -keystore '\
             "./.keys/*.keystore 'build/#{app}-unsigned.apk' '#{app}'"
      comm = "echo '#{key}' | #{comm}" if key
      sh comm
      FileUtils.cp "build/#{app}-unsigned.apk", "build/#{app}-signed.apk"
    end

    task :align do
      sh "zipalign -f -v 4 'build/#{app}-signed.apk' 'build/#{app}.apk'"
    end

    task :check do
      check_file("build/#{app}.apk")
    end

    task :submit do
      # Need to build a gem for this! Soon.
      # Fastlane for Android!
    end
  end

  #
  # Apple
  #
  desc 'Deploy to Apple’s App Store'
  task apple: [:release, :check_dirs, 'apple:all', :report]

  namespace :apple do
    task all: [:clean, :archive, :ipa, :check]

    # desc 'Clean up build folder from apks'
    task :clean do
      Dir['build/*.ipa'].each { |f| File.delete(f) }
    end

    task :archive do
      puts Paint["Build with release and device!", :red]
      sh 'cordova build ios --release --device'
      # xcodebuild -target "#{app}" -sdk "${TARGET_SDK}" -configuration Release
    end

    task :ipa do
      puts Paint["Signing iOS ipa!", :red]
      provision = Dir['platforms/ios/build/**/*.mobileprovision'].first
      developer = ENV['APPLE_DEVELOPER']
      developer = APPLE_DEVELOPER if Object.const_defined?(:APPLE_DEVELOPER)
      comm = 'xcrun -sdk iphoneos PackageApplication -v '\
             "'platforms/ios/build/emulator/#{app}.app' -o "\
             "'#{Rake.original_dir}/build/#{app}.ipa' "
      comm << "--embed '#{provision}'" if provision
      comm << "--sign #{APPLE_DEVELOPER}" if developer
      sh comm
    end

    task :check do
      check_file("build/#{app}.ipa")
    end
  end
end
