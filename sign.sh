#!/bin/bash

# Input Parameters
SOURCE_IPA="$1"
DEVELOPER_CERTIFICATE="$2"
MAIN_PROVISIONING_PROFILE="$3"
PLUGIN_PROVISIONING_PROFILE="$4"
OUTPUT_IPA_PATH="$5"
BUNDLE_IDENTIFIER="$6"
VERSION_NUMBER="$7"
BUILD_NUMBER="$8"
APP_GROUP_IDENTIFIER="$9"
TEAM_IDENTIFIER="${10}"

# Extract the IPA file
unzip -qo "$SOURCE_IPA" -d extracted

APPLICATION_NAME=$(ls extracted/Payload/)

# Replace the main application's provisioning profile
cp "$MAIN_PROVISIONING_PROFILE" "extracted/Payload/$APPLICATION_NAME/embedded.mobileprovision"

echo "Resigning with certificate: $DEVELOPER_CERTIFICATE"

# Update the Build Version and Build Number for the main application
if [[ "$VERSION_NUMBER" != "" ]]; then
    echo "Updating Build Version to: $VERSION_NUMBER"
    /usr/libexec/PlistBuddy -c "Set:CFBundleShortVersionString $VERSION_NUMBER" "extracted/Payload/$APPLICATION_NAME/Info.plist"
fi
if [[ "$BUILD_NUMBER" != "" ]]; then
    echo "Updating Build Number to: $BUILD_NUMBER"
    /usr/libexec/PlistBuddy -c "Set:CFBundleVersion $BUILD_NUMBER" "extracted/Payload/$APPLICATION_NAME/Info.plist"
fi

# Update the Bundle Identifier for the main application
if [[ "$BUNDLE_IDENTIFIER" != 'null.null' ]]; then
    echo "Changing Bundle Identifier to: $BUNDLE_IDENTIFIER"
    /usr/libexec/PlistBuddy -c "Set:CFBundleIdentifier $BUNDLE_IDENTIFIER" "extracted/Payload/$APPLICATION_NAME/Info.plist"
fi

# Extract entitlements from the main application's provisioning profile
security cms -D -i "$MAIN_PROVISIONING_PROFILE" > temp_entitlements_full.plist
/usr/libexec/PlistBuddy -x -c 'Print:Entitlements' temp_entitlements_full.plist > temp_entitlements.plist

# Find all components (apps, extensions, frameworks)
find -d extracted \( -name "*.app" -o -name "*.appex" -o -name "*.framework" \) > component_paths.txt

# Process and resign components
while IFS='' read -r component_path || [[ -n "$component_path" ]]; do
    if [[ "$component_path" == *".appex"* ]]; then
        echo "Processing extension: $component_path"

        # Remove existing signature
        rm -rf "$component_path/_CodeSignature/"

        # Replace provisioning profile for the extension
        cp "$PLUGIN_PROVISIONING_PROFILE" "$component_path/embedded.mobileprovision"

        # Extract entitlements for the extension
        security cms -D -i "$PLUGIN_PROVISIONING_PROFILE" > temp_entitlements_apex_full.plist
        /usr/libexec/PlistBuddy -x -c 'Print:Entitlements' temp_entitlements_apex_full.plist > temp_entitlements_apex.plist

        # Set the correct application identifier for OneSignal extension
        EXTENSION_BUNDLE_IDENTIFIER="$BUNDLE_IDENTIFIER.OneSignalNotificationServiceExtension"
        EXTENSION_APP_IDENTIFIER="$TEAM_IDENTIFIER.$EXTENSION_BUNDLE_IDENTIFIER"
        echo "Setting application identifier for .appex to: $EXTENSION_APP_IDENTIFIER"
        /usr/libexec/PlistBuddy -c "Set:application-identifier $EXTENSION_APP_IDENTIFIER" "temp_entitlements_apex.plist"

        # Add App Group Identifier to the extension's entitlements
        if [[ "$APP_GROUP_IDENTIFIER" != "" ]]; then
            echo "Adding App Group Identifier: $APP_GROUP_IDENTIFIER to .appex entitlements"
            /usr/libexec/PlistBuddy -c "Add:com.apple.security.application-groups array" "temp_entitlements_apex.plist" 2>/dev/null
            /usr/libexec/PlistBuddy -c "Add:com.apple.security.application-groups:0 string $APP_GROUP_IDENTIFIER" "temp_entitlements_apex.plist"
        fi

        # Update Build Version and Build Number for the extension
        if [[ "$VERSION_NUMBER" != "" ]]; then
            echo "Updating Build Version for extension: $component_path to $VERSION_NUMBER"
            /usr/libexec/PlistBuddy -c "Set:CFBundleShortVersionString $VERSION_NUMBER" "$component_path/Info.plist"
        fi
        if [[ "$BUILD_NUMBER" != "" ]]; then
            echo "Updating Build Number for extension: $component_path to $BUILD_NUMBER"
            /usr/libexec/PlistBuddy -c "Set:CFBundleVersion $BUILD_NUMBER" "$component_path/Info.plist"
        fi

        # Update Bundle Identifier for the extension
        echo "Changing .appex Bundle Identifier to: $EXTENSION_BUNDLE_IDENTIFIER"
        /usr/libexec/PlistBuddy -c "Set:CFBundleIdentifier $EXTENSION_BUNDLE_IDENTIFIER" "$component_path/Info.plist"

        # Resign the extension
        echo "Resigning the extension: $component_path"
        /usr/bin/codesign -f -s "$DEVELOPER_CERTIFICATE" --entitlements "temp_entitlements_apex.plist" "$component_path"

        # Cleanup temporary entitlements for the extension
        rm temp_entitlements_apex.plist temp_entitlements_apex_full.plist
    else
        # Resign other components
        /usr/bin/codesign -f -s "$DEVELOPER_CERTIFICATE" --entitlements "temp_entitlements.plist" "$component_path"
    fi
done < component_paths.txt

# Repackage the signed IPA
echo "Creating the Signed IPA"
cd extracted
zip -qry ../signed.ipa *
cd ..
mv signed.ipa "$OUTPUT_IPA_PATH"

# Cleanup temporary files and folders
rm -rf "extracted"
rm component_paths.txt
rm temp_entitlements.plist
rm temp_entitlements_full.plist

echo "Resigning complete. Signed IPA is available at: $OUTPUT_IPA_PATH"
