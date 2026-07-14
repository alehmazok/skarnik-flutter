---
name: testflight-release
description: Run iOS TestFlight release pipeline (analyze, test, build, upload) via ios/fastlane_testflight.sh. Use when user asks to release/ship/deploy iOS build to TestFlight, or run fastlane beta.
---

# TestFlight Release

Runs `ios/fastlane_testflight.sh` — chained fastlane lanes:
analyze_flutter → test_flutter → build_flutter → build_ios_release → beta (upload to TestFlight).

Chain uses `&&` — stops on first failure.

## Prereqs

- `ios/fastlane/.env.secret` must exist (dart-define secrets + Dotenv for Fastfile).
- Bundler gems installed (`bundle check` in `ios/`, else `bundle install`).
- Valid Apple signing/API key setup for `build_app` + `upload_to_testflight`.

## Run

```bash
cd ios && ./fastlane_testflight.sh
```

Long-running (analyze+test+build+sign+upload) — expect several minutes. Run in background, don't poll; surface final pass/fail + last error lines on completion.

## On failure

Report which lane failed (stdout shows lane name before failure) and tail relevant fastlane log. Don't re-run whole chain blind — fix root cause first (missing env, expired cert, test failure, etc).
