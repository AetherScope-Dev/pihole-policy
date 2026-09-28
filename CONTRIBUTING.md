# 🤝 Contributing

Thanks for helping improve Pi-hole Policy.

## Before opening a pull request

Please keep changes focused and explain the operational impact.

### Manifest changes

For new or changed upstream feeds:

1. Prefer the original publisher's HTTPS URL.
2. Confirm the feed is actively maintained.
3. Explain whether it belongs in **Standard** or **Hardened**.
4. Note known false-positive or usability risks.
5. Avoid feeds already substantially covered by the selected HaGeZi tier.
6. Do not commit generated copies of upstream blocklists.

### Script changes

- Keep scripts compatible with Bash on supported Pi-hole systems.
- Preserve client-specific lists and local domain rules.
- Avoid destructive database operations outside rows explicitly tagged as policy-managed.
- Run ShellCheck before submitting.

## Local validation

```bash
shellcheck scripts/*.sh
```

Review the manifests:

```bash
grep -RhvE '^[[:space:]]*(#|$)' manifests/
```

## Pull requests

A useful PR description should include:

- what changed
- why it changed
- expected benefit
- compatibility impact
- false-positive or operational risk
- how it was tested

## Security issues

Please do not publish exploitable vulnerabilities in a public issue. See [SECURITY.md](SECURITY.md).
