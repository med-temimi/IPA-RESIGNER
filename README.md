# IPA-RESIGNER

This guide provides step-by-step instructions to resign an IPA file using the provided `sign.sh` and `signall.sh` scripts.

## Prerequisites
Ensure you have the following:

1. The source IPA file you want to resign.
2. Developer certificate installed on your machine (Certificate name required).
3. Main and plugin provisioning profiles (.mobileprovision files).
4. Required inputs:
   - Bundle Identifier
   - Version Number (optional)
   - Build Number (optional)
   - App Group Identifier (if applicable)
   - Team Identifier
5. A Unix-based environment (macOS or Linux) with the following tools installed:
   - Bash
   - `PlistBuddy`
   - `security`
   - `codesign`
   - `zip`

---

## Script Overview

### 1. `sign.sh`
This script is used to resign a single IPA file with updated provisioning profiles, bundle identifiers, version numbers, and build numbers.

### 2. `signall.sh`
This script extends the functionality of `sign.sh` to process IPAs files in a directory.

---

## Steps to Resign an IPA File

### 1. Prepare the Environment

- Ensure the two scripts has executable permissions:
  ```bash
  chmod +x /PATH_TO_SIGN_SH_FILE/sign.sh
  chmod +x /PATH_TO_SIGNALL_SH_FILE/signall.sh
  ```

### 2. Execute the Script:


#### Parameters:
- `<source_directory>`: Path to the directory containing IPA files to resign.
- `<developer_certificate>`: Name of the installed developer certificate.
- `<main_provisioning_profile>`: Path to the main provisioning profile.
- `<plugin_provisioning_profile>`: Path to the plugin provisioning profile.
- `<output_directory>`: Directory where resigned IPA files will be saved.
- `<bundle_identifier>`: New bundle identifier for the apps.
- `<version_number>`: (Optional) New version number.
- `<build_number>`: (Optional) New build number.
- `<app_group_identifier>`: (Optional) App group identifier.
- `<team_identifier>`: Team identifier associated with the certificate.


Run the following command:

```bash
    sh signall.sh
```

---

## Notes

1. Ensure that the provisioning profiles and certificates match the bundle identifier and team.
2. Use absolute paths for the inputs to avoid errors.
3. Both scripts will generate resigned IPA files in the specified output location.
4. Check the console output for any errors during the process.
4. Once the process is complete, the message:
       "Resigning complete. Signed IPA is available at: XXX/XXXXXXXX"
   will be displayed in the console.

---

## Troubleshooting

- **Permission Denied**: Ensure the script files have executable permissions (`chmod +x`).
- **Invalid Certificate**: Verify that the developer certificate is installed and valid.
- **Mismatch Errors**: Ensure the provisioning profiles and certificate match the app’s bundle identifier and team.

---

