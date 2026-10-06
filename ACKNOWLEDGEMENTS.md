# Acknowledgements

This skill's content is original, but its shape borrows ideas from other published agent skills. Thank you to their authors.

- **Expo — [`expo-web-to-native`](https://github.com/expo/skills/tree/main/plugins/expo/skills/expo-web-to-native)** (MIT): a migration "spine" that orders the work and defers idioms to other skills; a durable worklist; "false friends" idiom tables; verify by running, not compiling; running the migration as a goal loop.
- **Callstack — [`assess-react-native-migration`](https://github.com/callstackincubator/agent-skills)** (MIT): phase gates, evidence labels (`observed` / `assumed` / `unknown`) with file citations, one-question-per-turn interviewing, representative-and-hard checkpoint flows, faithful pass then idiomatic pass, tabular migration inventories.
- **Google — [Android skills](https://github.com/android/skills)**, especially `migrate-xml-views-to-jetpack-compose`: capture a baseline before migrating, a preview for every new composable, iterate on preview vs baseline until parity, then write a UI test. Also the Android CLI tooling the Android verification loop is built on.
- **Antoine van der Lee — [`swiftui-expert-skill`](https://github.com/AvdLee/SwiftUI-Agent-Skill)**: the topic-router layout, and the SwiftUI guidance this skill delegates to.
- **[XcodeBuildMCP](https://github.com/getsentry/XcodeBuildMCP)**: the iOS build/run/UI-automation loop.
- **[`swift-ios-skills`](https://github.com/dpearson2699/swift-ios-skills)**: topic skills this skill delegates to for iOS depth.
