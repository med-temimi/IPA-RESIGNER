#!/bin/bash
# Paths
SIGNING_SCRIPT="/PATH_TO_SIGN_SH_FILE/sign/sign.sh"
IPA_SOURCE_FOLDER="/PATH_TO_IPA_FOLDER/ipa"
SIGNED_IPA_DEST_FOLDER="/PATH_TO_SIGNED_IPA_FOLDER/"

# Signing credentials and configuration
CERTIFICATE="xxxxx Xxxxx: xxxxxx (xxxxxxx)"
MAIN_PROVISIONING_PROFILE="/PATH_TO_MAIN_PROVISIONING_PROFILE/profile.mobileprovision"
PLUGIN_PROVISIONING_PROFILE="/PATH_TO_ONESIGNAL_PROVISIONING_PROIFLE/plugins.mobileprovision"
BUNDLE_IDENTIFIER="com.xxx.xxxxxx"
BUILD_VERSION="1.0.0"
BUILD_NUMBER="1"
APP_GROUP_ID="group.com.xxx.xxxxxxxx.onesignal"
TEAM_ID="XXXXXXXXXX"

# Navigate to the source folder containing IPA files
cd "$IPA_SOURCE_FOLDER"

# Find IPA files in the folder and list them in files.txt
find -d . -type f -name "*.ipa" > ipa_files.txt

# Process IPA files
while IFS='' read -r ipa_file || [[ -n "$ipa_file" ]]; do
    # Extract the base filename (without extension)
    IPA_FILENAME=$(basename "$ipa_file" .ipa)
    echo "Processing IPA: $IPA_FILENAME"

    # Construct the output path for the signed IPA
    SIGNED_IPA_PATH="${SIGNED_IPA_DEST_FOLDER}${IPA_FILENAME}_signed.ipa"

    # Call the signing script with the required arguments
    "$SIGNING_SCRIPT" \
        "$ipa_file" \
        "$CERTIFICATE" \
        "$MAIN_PROVISIONING_PROFILE" \
        "$ONESIGNAL_PROVISIONING_PROFILE" \
        "$SIGNED_IPA_PATH" \
        "$BUNDLE_IDENTIFIER" \
        "$BUILD_VERSION" \
        "$BUILD_NUMBER" \
        "$APP_GROUP_ID" \
        "$TEAM_ID"
done < ipa_files.txt

# Clean up temporary files
rm ipa_files.txt
