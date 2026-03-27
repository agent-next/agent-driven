---
description: Security rules for all agent operations
---

# Security Rules

- NEVER commit credentials, tokens, API keys, or .env files
- NEVER force push to any branch
- NEVER use `--no-verify` to skip hooks
- NEVER expose stack traces in production error responses
- NEVER use `eval()` or dynamic code execution from user input
- NEVER commit files over 50MB
- Validate all user input at system boundaries
- Use parameterized queries, never string concatenation for SQL
- Use constant-time comparison for secrets (hmac.compare_digest)
