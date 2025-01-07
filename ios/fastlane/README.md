fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios analyze_flutter

```sh
[bundle exec] fastlane ios analyze_flutter
```

Runs analyzer

### ios test_flutter

```sh
[bundle exec] fastlane ios test_flutter
```

Runs flutter widget tests

### ios build_flutter

```sh
[bundle exec] fastlane ios build_flutter
```

Build flutter release ipa

### ios build_ios_release

```sh
[bundle exec] fastlane ios build_ios_release
```

Build and sign iOS Release app

### ios build_ios_adhoc

```sh
[bundle exec] fastlane ios build_ios_adhoc
```

Build and sign iOS AdHoc app

### ios firebase

```sh
[bundle exec] fastlane ios firebase
```

Deploy ipa to Firebase App Distribution

### ios beta

```sh
[bundle exec] fastlane ios beta
```

Push a new build to TestFlight

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
