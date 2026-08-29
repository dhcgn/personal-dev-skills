---
description: PowerShell code style
applyTo: "**/*.ps1"
---

- Use Write-Progress for long-running operations to provide feedback to the user.
- Add a Powershell comment-based help block at the top of each script to provide usage information.
- Check Non-native commands before executing them to ensure they are available on the system.
- If script requires elevated privileges, check for administrative rights at the beginning of the script and provide a clear message if not running as an administrator.
- Try to ensure idempotence to avoid unintended side effects when running scripts multiple times.
- A cancelation mechanism should be implemented for long-running scripts, allowing users to stop the script gracefully and clean up any resources or temporary files.