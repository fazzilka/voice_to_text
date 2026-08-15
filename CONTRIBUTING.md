# Contributing

Issues and pull requests are welcome. Please keep changes focused, preserve
local-only transcription, and test on an Apple Silicon Mac running macOS 14 or
newer.

Before opening a pull request, run:

```bash
./scripts/check.sh
./scripts/security-audit.sh
swift run --package-path core VoiceToTextCoreChecks
swift run -c debug --package-path swift VoiceToText --self-test all
./scripts/build-app.sh ./dist/VoiceToText.app
```

Use the branch conventions documented in [docs/GITFLOW.md](docs/GITFLOW.md).
Do not combine unrelated features, fixes, and refactors in one pull request.

The release version in `swift/Info.plist` and `install.sh` must match. Release
assets are immutable: publish a new version instead of replacing an existing
ZIP, then update the pinned SHA-256 in `install.sh`.
