---
name: pr-review-comments
description: Fetch and address code-review comments on a GitHub PR for this repo (alehmazok/skarnik-flutter) — bot or human. Use when user says "work on PR comments", "address review feedback", "fix PR #N comments", or pastes a PR URL asking to act on its reviews.
---

# PR Review Comments

## 1. Identify the PR and its branch

```bash
gh pr view <number-or-url> --json title,body,state,headRefName,baseRefName,url
```

`headRefName` is the branch to work on. Check out/confirm the correct local branch — a PR's head
branch may differ from whatever branch is currently checked out (e.g. a later commit landed on it
from a differently-named local branch). Don't assume; verify with `git branch --show-current` and
switch if needed.

## 2. Fetch all feedback

Three separate sources — check all of them, a PR can have comments in any/all:

```bash
# Inline diff/line comments (bot reviewers like kilo-code-bot, human line comments)
gh api repos/alehmazok/skarnik-flutter/pulls/<number>/comments --paginate

# Top-level review summaries (e.g. a bot's "Code Review Summary" issue comment)
gh api repos/alehmazok/skarnik-flutter/issues/<number>/comments

# Formal review objects (APPROVED/CHANGES_REQUESTED/COMMENTED state)
gh api repos/alehmazok/skarnik-flutter/pulls/<number>/reviews
```

Use `--jq` to trim to `{path, line, body, user: .user.login}` when scanning many comments to save
context.

## 3. Triage each comment — verify before fixing

Read the actual current file at the flagged path/line (not just the diff hunk in the comment body —
the file may have moved on since the comment was posted). Confirm the claim is real:

- If valid → fix it.
- If stale (already fixed) or wrong (bot misread the code) → skip, and be ready to explain why if
  asked. Don't blindly apply bot suggestions — treat them as a lead to verify, same as any other
  finding.

## 4. Fix, verify, commit

- Apply the fix.
- Run `flutter analyze --no-fatal-infos` and `flutter test` (whole suite or the touched feature's
  test dir) before committing — same bar as any other change in this repo.
- One commit per logical fix (or bundle trivially related ones), message states what was wrong and
  why the fix addresses it — not "address PR feedback" as the whole message.
- New commits, not amends — the PR history should show the review cycle.

## 5. Push and reply

- Pushing to the PR branch is a shared/visible action — confirm with the user before `git push`,
  per this session's standing risk rules, unless they've already told you to push as part of the
  request.
- Only reply to individual review-comment threads on GitHub (`gh api
  repos/alehmazok/skarnik-flutter/pulls/<number>/comments/<comment_id>/replies -f body=...`) if the
  user asks for that — posting to the PR is visible to collaborators, don't do it proactively.
