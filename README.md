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
rake compile:html     # Compiles HAML -> HTML
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
HAML -> HTML
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

### HAML

You may use ERB tags anywhere in haml.
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


### Binaries

Make sure you have `xcrun`.
Also you need to open the project once in Xcode. (working on xproject gem)

### Developer

To change developer per project:

    APPLE_DEVELOPER = 'Developer X (XXXXX)'


## YAMG - Yet Another Media Generator

To generate icons, splashes and screenshots check out:

https://github.com/nofxx/yamg
