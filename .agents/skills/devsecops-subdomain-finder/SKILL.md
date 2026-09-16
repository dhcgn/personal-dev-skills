---
name: devsecops-subdomain-finder
description: Enumerate subdomains of an apex domain via Certificate Transparency log search. Use when the user asks to find, enumerate, or discover subdomains of a domain (recon, attack-surface mapping, CT log lookup). Examples of triggers - "find subdomains of example.org", "enumerate the attack surface for acme.com", "which hostnames exist for this domain?"
---

# Subdomain finder via Certificate Transparency

Query CT-log search endpoints for certificates issued against an apex domain and
report the union of discovered hostnames.

## Workflow

1. **Validate the apex.** Strip scheme/paths and confirm the input is an apex
   or registrable domain (`example.org`, not `https://example.org/x`).
2. **Query both sources** (replace `example.org` with the apex):

   ```text
   GET https://crt.name/v1/search?apex=example.org
   GET https://api.sub.md/v1/search?apex=example.org
   ```

   Both return **plain text, one hostname per line** (no JSON wrapper). HTTP 200
   with an empty body means no results. Use the `webfetch` tool or `curl`/`Invoke-RestMethod`.
   Timeout ~15 s each; the two calls are independent and can run in parallel.
3. **Merge and clean:**
   - Trim whitespace, drop empty lines, lowercase.
   - Deduplicate across both sources.
   - Keep only names ending in `.apex` (or the apex itself). Both endpoints can
     return wildcard entries; report `*.apex` as-is.
4. **Report**, sorted alphabetically, with per-source coverage:

   ```text
   142 unique hostnames for example.org
     crt.name: 130 | sub.md: 128 | both: 116
   ```

## Notes

- **CT is passive recon**: it only reveals hostnames that appear in issued
  certificates (including expired and precertificates). Absence from the list
  does not mean the host does not exist — internal hosts and non-TLS services
  never appear in CT logs.
- **Coverage differs between the sources** (they query different log mirrors);
  always query both and merge rather than trusting one.
- Results include long-dead hosts from expired certs. Do not present the list
  as "live infrastructure" — offer a liveness check (DNS resolve / HTTP probe)
  as a follow-up if the user wants it.
- Authorization: subdomain enumeration is read-only against public CT logs, but
  confirm the target is the user's own asset or in scope before probing
  discovered hosts further.
