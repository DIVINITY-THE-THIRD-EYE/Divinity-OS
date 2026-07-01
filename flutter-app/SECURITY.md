# Security Policy

## Supported Versions

| Version | Supported |
|---------|-----------|
| Latest  | ✅ |
| Older   | ❌ |

## Reporting a Vulnerability

**Please do NOT open a public GitHub issue for security vulnerabilities.**

### How to Report

Send an email to: **security@divinitythethirdeye.com**

Include:
- Description of the vulnerability
- Steps to reproduce
- Potential impact (data exposure, unauthorized access, etc.)
- Your contact information (for follow-up questions)

### What Happens Next

1. **Acknowledgement** within 48 hours
2. **Initial assessment** within 5 business days
3. **Fix + patch release** within 30 days for critical issues
4. **Credit** in the release notes (if you'd like to be named)

### Scope

The following are **in scope**:
- Supabase RLS policy bypasses
- Authentication flaws (unauthorized role escalation)
- Payment data exposure
- Personally identifiable information (PII) leaks
- Server-side injection vulnerabilities

The following are **out of scope**:
- Denial of service attacks
- Social engineering
- Issues requiring physical device access
- Vulnerabilities in third-party dependencies (report those to the dependency maintainer)

## Security Architecture

- **Database**: Row-Level Security on all tables; `is_admin`/`is_trainer` security-definer helpers
- **Auth**: Supabase Auth with JWT role sync; Firebase App Check
- **Storage**: Payment screenshots in private bucket with signed URLs
- **Transport**: HTTPS only; TLS enforced via network security config
- **Secrets**: No secrets in repository; all via environment variables or `--dart-define`
