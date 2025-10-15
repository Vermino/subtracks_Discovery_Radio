#!/bin/bash
# Script to add namespace declarations to Flutter packages for AGP 8.x compatibility

add_namespace() {
    local build_gradle="$1"
    local manifest_xml="$2"
    
    # Extract package name from AndroidManifest.xml
    if [ ! -f "$manifest_xml" ]; then
        echo "Warning: AndroidManifest.xml not found at $manifest_xml"
        return 1
    fi
    
    local package_name=$(grep -oP 'package="\K[^"]+' "$manifest_xml" | head -1)
    if [ -z "$package_name" ]; then
        echo "Warning: Could not extract package name from $manifest_xml"
        return 1
    fi
    
    # Check if namespace already exists
    if grep -q "^\s*namespace" "$build_gradle"; then
        echo "Namespace already exists in $build_gradle"
        return 0
    fi
    
    # Add namespace after the android { line
    sed -i "/^android {/a\    namespace '$package_name'" "$build_gradle"
    echo "Added namespace '$package_name' to $build_gradle"
}

# Find all Flutter packages in pub cache
PUB_CACHE="${LOCALAPPDATA}/Pub/Cache"

# Fix packages in hosted cache
for pkg_dir in "$PUB_CACHE"/hosted/pub.dev/*/android; do
    if [ -f "$pkg_dir/build.gradle" ] && [ -f "$pkg_dir/src/main/AndroidManifest.xml" ]; then
        add_namespace "$pkg_dir/build.gradle" "$pkg_dir/src/main/AndroidManifest.xml"
    fi
done

# Fix packages in git cache
for pkg_dir in "$PUB_CACHE"/git/*/android; do
    if [ -f "$pkg_dir/build.gradle" ] && [ -f "$pkg_dir/src/main/AndroidManifest.xml" ]; then
        add_namespace "$pkg_dir/build.gradle" "$pkg_dir/src/main/AndroidManifest.xml"
    fi
done

# Also check nested packages in git repos
for pkg_dir in "$PUB_CACHE"/git/*/*/android; do
    if [ -f "$pkg_dir/build.gradle" ] && [ -f "$pkg_dir/src/main/AndroidManifest.xml" ]; then
        add_namespace "$pkg_dir/build.gradle" "$pkg_dir/src/main/AndroidManifest.xml"
    fi
done

echo "Done fixing namespaces!"

# Clean Gradle cache to force rebuild with new namespaces
echo ""
echo "Cleaning Gradle cache..."
if [ -d "android" ]; then
    cd android
    if [ -f "gradlew" ]; then
        ./gradlew clean > /dev/null 2>&1
        echo "Gradle cache cleaned successfully"
    else
        echo "Warning: gradlew not found, skipping Gradle clean"
    fi
    cd ..
else
    echo "Warning: android directory not found, skipping Gradle clean"
fi

echo ""
echo "✓ Ready to build! Run: flutter build apk --debug"
