#
#
# Deploy!
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
      sh " cordova build --release android"
      FileUtils.cp 'platforms/android/build/outputs'\
                   '/apk/android-release-unsigned.apk',
                   "build/#{app}-unsigned.apk"
    end

    task :sign do
      key = ENV['GOOGLE_KEY']
      key = GOOGLE_KEY if Object.const_defined?(GOOGLE_KEY)
      sh "echo '#{key}' | jarsigner -verbose -sigalg SHA1withRSA "\
         "-digestalg SHA1 -keystore "\
         "./.keys/google.keystore build/#{app}-unsigned.apk #{app}"
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
  task apple: [:check_dirs, 'apple:all', :report]

  namespace :apple do
    task :all   => [:archive, :ipa, :check] #, :upload]

    task :archive do
      sh "cordova build --release ios"
      # xcodebuild -target "#{app}" -sdk "${TARGET_SDK}" -configuration Release
    end

    task :ipa do
      provision = Dir['platforms/ios/build/**/*.mobileprovision'].first
      developer = ENV['APPLE_DEVELOPER']
      developer = APPLE_DEVELOPER if Object.const_defined?(:APPLE_DEVELOPER)
      comm = "xcrun -sdk iphoneos PackageApplication -v "\
             "'platforms/ios/build/emulator/#{app}.app' -o "\
             "'#{Rake.original_dir}/build/#{app}.ipa' "
      comm << "--embed '#{provision}'" if provision
      comm << "--sign #{APPLE_DEVELOPER}" if developer
      sh comm
    end

    task :check do
      arch = "build/#{app}.ipa"
      if File.exists? arch
        puts "Build done! #{arch} #{File.size(arch).to_f/(1024 * 1024)} Mb"
      else
        puts "Something BAD! No #{arch}!"
        exit 1
      end
    end

  end
end
