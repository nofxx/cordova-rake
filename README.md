# Rake Cordova

[![Gem Version](https://badge.fury.io/rb/cordova-rake.png)](http://badge.fury.io/rb/cordova-rake)

The missing cordova tasks. And the better: On Ruby!

## Install

    gem install cordova-rake


## Use

Add to your `Rakefile`

    require 'cordova-rake'

If you don't have one

    echo "require 'cordova/rake'" > Rakefile


## From Rake

```
rake compile         # Compiles all resources
rake compile:css     # Compiles SASS -> CSS
rake compile:html    # Compiles HAML -> HTML
rake compile:js      # Compiles Coffee -> JS
rake compile:vars    # Postcompile ENV variables
rake release:apple   # Deploy to Apple’s App Store
rake release:google  # Deploy to Google’s Play Store
rake ripple          # Prepare & Ripple emulate
rake run:android     # Run on Android device or emulator
rake run:ios         # Run on iOS plugged device or emulator
rake serve           # Phonegap Dev App, optional: port
rake setup           # Setup env for development
```


## Google Play Store


### Binaries

Make sure you have `jarsigner` and `zipalign` on your path.
The latter is usually somewhere in /opt/android-sdk.


### Key password

To avoid typing keys on eack apk build:
Rakefile:

    GOOGLE_KEY = 'mykeypassword'

Or an ENV var 'GOOGLE_KEY'
