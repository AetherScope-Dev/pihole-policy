# 🔐 Security Policy

## Reporting a vulnerability

If you identify a vulnerability in the bootstrap, synchronization logic, repository workflows, or another component that could cause unauthorized modification, command execution, credential exposure, or destructive Pi-hole changes, please report it privately to the repository owner rather than opening a public issue.

If private reporting is unavailable, open a minimal public issue requesting a private contact channel without publishing exploit details.

## Scope

Security reports are especially useful for:

- command injection
- unsafe handling of remote manifest content
- privilege-boundary problems
- destructive database behavior
- GitHub Actions workflow vulnerabilities
- supply-chain or update-integrity weaknesses

Blocklist false positives and ordinary upstream-feed quality issues are not software vulnerabilities and may be reported through a normal issue.

## Supported version

Security fixes target the current `main` branch and the latest published release.
