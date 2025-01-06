fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## Android

### android analyze

```sh
[bundle exec] fastlane android analyze
```

Runs analyzer

### android test

```sh
[bundle exec] fastlane android test
```

Runs widget tests

### android appbundle

```sh
[bundle exec] fastlane android appbundle
```

Build release appbundle

### android apk

```sh
[bundle exec] fastlane android apk
```

Build staging apk

### android firebase

```sh
[bundle exec] fastlane android firebase
```

Deploy apk to Firebase App Distribution

### android playstore_internal

```sh
[bundle exec] fastlane android playstore_internal
```

Deploy appbundle to Google Play Store. Internal track.

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
