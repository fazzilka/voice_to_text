# Security

Please report a suspected vulnerability privately through GitHub's
**Security > Report a vulnerability** page for this repository. Do not include
private transcript text, audio, credentials, or full diagnostic logs in a
public issue.

VoiceToText does not require an account or cloud transcription service. The
release installer verifies SHA-256, version, bundle identifier, architecture,
code signature, and required microphone entitlements. It does not disable
Gatekeeper with `xattr`. The `0.1.0` public archive has not been published yet;
its all-zero checksum is an explicit pre-release placeholder and the README
only documents local builds at this stage.

The current local bundle is ad-hoc signed and is not notarized by Apple. The
verified local build workflow is documented in [README.md](README.md).

The latest source and artifact review is documented in
[docs/SECURITY_AUDIT.md](docs/SECURITY_AUDIT.md). Run
`./scripts/security-audit.sh` before every pull request.
