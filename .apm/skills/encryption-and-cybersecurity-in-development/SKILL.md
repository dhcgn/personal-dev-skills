---
name: encryption-and-cybersecurity-in-development
description: >
  A brief overview of encryption and how it is used to secure data. 
---

- Use already established encryption libraries and algorithms rather than implementing your own.
- For portable encryption files, use a standard format such as age-encryption <https://github.com/FiloSottile/age>
- Password-based encryption should use a key derivation function (KDF) 
- Use Proof-of-Work (PoW) to prevent brute-force attacks
- Use the common best practices like from OWASP