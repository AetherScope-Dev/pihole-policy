# Changelog

All notable changes to this project are documented here.

The project follows semantic versioning for public releases.

## [1.0.0] - 2026-09-28

### Added

- Standard and Hardened Pi-hole policy tiers
- Centralized GitHub policy manifests
- Pi-hole v6 bootstrap installer
- Daily client reconciliation
- Policy-managed subscription tagging
- Preservation of client-specific local rules
- Deployment verification script
- Client deployment cookbook
- GPL-3.0 licensing and upstream attribution
- GitHub Actions validation for shell scripts and manifests
- Tag-driven GitHub release workflow
- Contribution and security guidance

### Security posture

The Hardened tier includes additional high-control feeds such as newly registered domains, abused TLDs, badware hosting, and DNS-bypass infrastructure. These controls intentionally accept a higher false-positive rate.
