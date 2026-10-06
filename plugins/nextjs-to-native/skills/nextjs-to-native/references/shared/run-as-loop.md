# Run the screen loop unattended

Phases 7–8 of [`nextjs-to-native`](../../SKILL.md). The screen loop is a repeat-until-done task over a durable worklist, which fits a loop runner: Claude Code `/loop` (self-paced when given no interval), or any harness that re-injects one objective until a stop condition holds. The objective re-reads this skill every iteration so the playbook and the worklist survive context compaction and new sessions.

Only start the loop after phase 6 passed: the patterns in the app's `CLAUDE.md` are what keep unattended iterations consistent.

## Objective template

Fill the `<…>` slots and hand it to the loop runner. If the harness cannot loop, save it as `migration/LOOP.md` and tell the user how to launch it.

```
Goal: migrate the <PLATFORM: Android (Compose) | iOS (SwiftUI)> app for <APP NAME>
from its Next.js website, one screen per iteration, following the nextjs-to-native skill.

Every iteration, FIRST re-read the nextjs-to-native SKILL.md, the app's CLAUDE.md,
and migration/SCREENS.md. Then:

1. Take the top unchecked `nativize` screen for <PLATFORM> in migration/SCREENS.md.
   If none remain unresolved (all done or blocked), STOP and report: screens done,
   screens blocked with reasons, and anything that needs a human.
2. Read its spec in migration/screens/<id>.md and its baselines.
   <LEAD-FOLLOW ONLY: also read the lead platform's implementation of this screen
   for resolved decisions; the web baseline remains the spec of record.>
3. Implement it following CLAUDE.md patterns, the platform false-friends and
   patterns references, and brand-vs-platform rules (visual mode: <brand-first|platform-first>).
   Reuse existing primitives; add a new primitive to the gallery only if the web has it.
4. Verify per references/shared/verify.md: previews for every state, run on the
   <emulator|simulator>, compare against baselines (content → behavior → visual →
   platform behavior). Fix code-caused failures now.
5. Add the UI test. Build and run the full test suite; the app must stay green.
6. Update migration/SCREENS.md with ONE line for this screen:
   "<id> — done (<short note>)" or
   "<id> — blocked: <reason> — needs <what would unblock>".
   Record parity results in migration/PARITY_CHECKS.md. Commit with message
   "feat(<platform>): <screen id>".

Rules: one screen per iteration. Never revisit a blocked screen without new
information. Never edit generated API code, project files guarded by hooks, or
web baselines. Never touch `later` or `drop` screens. Ask nothing mid-loop; if a
decision is needed, mark the screen blocked with the question.

Backend base URL (staging): <URL>
Test account: read from <path to local, git-ignored credentials file>
```

## Parallel or lead-follow with multiple agents

- Use one git worktree per platform (or per screen batch) so agents do not edit the same files.
- Never let two agents implement screens that introduce the same new primitive at the same time; build shared primitives first (phase 5) or serialize those screens.
- The human review queue is the real bottleneck: size the batch to what can be reviewed, not to what agents can generate.
