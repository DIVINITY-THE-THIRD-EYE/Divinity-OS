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
- Potential impact (data exposure, site takeover, etc.)
- Your contact information (for follow-up questions)

### What Happens Next

1. **Acknowledgement** within 48 hours
2. **Initial assessment** within 5 business days
3. **Fix + patch release** within 30 days for critical issues
4. **Credit** in the release notes (if you'd like to be named)

### Scope

The following are **in scope**:
- Cross-Site Scripting (XSS) on marketing pages
- Subversion of Content Security Policies (CSP) or security headers
- Open redirects or server configuration leaks
- Personally identifiable information (PII) leaks from contact/subscribe forms

The following are **out of scope**:
- Denial of service attacks
- Social engineering
- Issues requiring physical device access or social engineering of domain registrars
- Vulnerabilities in third-party npm packages (report those to the package maintainer)

## Security Architecture

- **Hosting**: Vercel managed platform with automatic TLS configuration
- **Transport**: HTTPS terminated by Vercel; HSTS headers enabled
- **Sanitization**: Standard React DOM rendering protecting against raw XSS vectors
- **Secrets**: Frontend secrets restricted entirely to compile-time `NEXT_PUBLIC_` environments; DB secret keys never exposed to client bundles
