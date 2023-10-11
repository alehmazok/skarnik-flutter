#!/usr/bin/env bash
bundle exec fastlane test_flutter &&
  bundle exec fastlane build_flutter &&
  bundle exec fastlane build_ios_release &&
  bundle exec fastlane beta
