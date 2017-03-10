# Rake Cordova

[![Gem Version](https://badge.fury.io/rb/cordova-rake.svg)](http://badge.fury.io/rb/cordova-rake)
[![Build Status](https://travis-ci.org/nofxx/cordova-rake.svg?branch=master)](https://travis-ci.org/nofxx/cordova-rake)
[![Dependency Status](https://gemnasium.com/nofxx/cordova-rake.svg)](https://gemnasium.com/nofxx/cordova-rake)

The missing cordova tasks. And the better: On Ruby!

## Install

    gem install cordova-rake


## Use

Add to your `Rakefile`

    require 'cordova/rake'

If you don't have one

    echo "require 'cordova/rake'" > Rakefile


## rake -T

```
rake compile          # Compiles all resources
rake compile:css      # Compiles SASS -> CSS
rake compile:html     # Compiles HAML/SLIM -> HTML
rake compile:js       # Compiles Coffee -> JS
rake compile:vars     # Postcompile ENV variables
rake emulate:android  # Run on Android emulator
rake emulate:ios      # Run on iOS emulator
rake guard            # Prepare & Ripple emulate
rake release          # Compiles all resources with ENV=production
rake release:apple    # Deploy to Apple’s App Store
rake release:google   # Deploy to Google’s Play Store
rake ripple           # Prepare & Ripple emulate
rake run:android      # Run on Android device or emulator
rake run:ios          # Run on iOS plugged device or emulator
rake serve            # Phonegap Dev App, optional: port
rake setup            # Setup env for development
```

# Guard + Compile

Just run `guard`. Or directly `rake`.
```
HAML/SLIM -> HTML
SASS -> CSS
COFFEE -> JS
```
Right into www/

## Config

Create a config/app.yml:

```
development:
  server: '10.1.1.88:3000'
production:
  server: 'site.com'
```

This postcompiles ERB tags `<%= server %>` into the env's value.

Example `file.coffee`:

    apiURL = 'http://<%= server %>'

Will render `file.js` in production:

    apiURL = 'http://site.com'

### HAML/SLIM

Choose and uncomment the line on your `Gemfile`.
Also: You may use ERB tags anywhere in haml/slim.
You may also use ERB logic if wanted.

Tip: to precompile more than once the same ERB tag: `<%%= value %>`.
First time it'll compile to `<%= value %>`.

### Coffee

Content replaced must be inside a string.


### SASS

To precompile a value that must not contain quotes (eg colors):
Use `unquote('<%= value %>')`:

```sass
.btn
  color: unquote('<%= color %>')
```

Will render CSS:

```sass
.btn {
  color: #FF3311;
}
```

# Deploy

## Google | Play Store


### Binaries

Make sure you have `jarsigner` and `zipalign` on your path.
The latter is usually somewhere in /opt/android-sdk.


### Key password

To avoid typing keys on eack apk build:
Rakefile:

    GOOGLE_KEY = 'mykeypassword'

Or an ENV var 'GOOGLE_KEY'


## Apple | App Store

Use **fastlane**. Going to add it to rake in next release.

https://github.com/KrauseFx/fastlane

### Binaries

Make sure you have `xcrun`.
Also you need to open the project once in Xcode. (working on xproject gem)

### Developer

To change developer per project:

    APPLE_DEVELOPER = 'Developer X (XXXXX)'

## SANITY MODE

This means: code, commit, `single command to do all store upload drama`

### iOS

Fastlane integration:

https://github.com/KrauseFx/fastlane


### Android

#### Install


    yaourt -S android-sdk android-sdk-platform-tools android-udev

Latest:

    yaourt -S android-platform android-sdk-build-tools

Version:

    yaourt -S android-platform-XX android-sdk-build-tools-XX

Add M2:

    android update sdk --no-ui --all --filter "extra-android-m2repository"


#### Deploy

Capkin integration:

https://github.com/fireho/capkin


## YAMG - Yet Another Media Generator

To generate icons, splashes and screenshots check out:

https://github.com/nofxx/yamg
